import Foundation
import Speech
import AVFoundation

public actor SystemSpeechRecognizer: SpeechRecognizer {
    private var audioEngine: AVAudioEngine?
    private var captureSession: AVCaptureSession?
    private var captureDelegate: CaptureOutputDelegate?
    private var captureQueue: DispatchQueue?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?
    private var isRunning = false
    private var tapNode: AVAudioNode?
    private var tapBus: AVAudioNodeBus = 0

    public init() {}

    public func requestAuthorization() async -> SpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: Self.mapStatus(status))
            }
        }
    }

    public func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error> {
        try await startRecognition(locale: locale, retryOnInvalidElement: true)
    }

    private func startRecognition(locale: Locale, retryOnInvalidElement: Bool) async throws -> AsyncThrowingStream<String, Error> {
        guard !isRunning else { throw SpeechRecognizerError.alreadyRunning }
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechRecognizerError.unavailable
        }

        let hasMicAccess = await requestMicrophoneAccess()
        guard hasMicAccess else { throw SpeechRecognizerError.microphoneDenied }
        guard recognizer.supportsOnDeviceRecognition else { throw SpeechRecognizerError.onDeviceNotSupported }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true

        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone, .external],
            mediaType: .audio,
            position: .unspecified
        ).devices
        print("Speech devices:", devices.map(\.localizedName))
        guard !devices.isEmpty else { throw SpeechRecognizerError.inputDeviceUnavailable }

        let bufferSize: AVAudioFrameCount = 2048
        let strategies: [AudioCaptureStrategy] = [
            .captureSession,
            .inputNodeFormat,
            .inputNodeNilFormat,
            .mixerNodeFormat
        ]

        var lastError: NSError?
        var selectedEngine: AVAudioEngine?

        for strategy in strategies {
            do {
                switch strategy {
                case .captureSession:
                    try startCaptureSession(request: request)
                    print("Speech capture strategy:", strategy.rawValue)
                    break
                case .inputNodeFormat, .inputNodeNilFormat, .mixerNodeFormat:
                    let engine = AVAudioEngine()
                    try configureEngine(
                        engine: engine,
                        request: request,
                        bufferSize: bufferSize,
                        strategy: strategy
                    )
                    selectedEngine = engine
                    print("Speech capture strategy:", strategy.rawValue)
                }

                if captureSession != nil || selectedEngine != nil {
                    break
                }
            } catch {
                let nsError = error as NSError
                lastError = nsError
                print("Speech capture failed:", strategy.rawValue, "error:", nsError.code, nsError.localizedDescription)
                cleanupTap()
                stopCaptureSession()
                if nsError.code == -10877 {
                    continue
                }
            }
        }

        guard captureSession != nil || selectedEngine != nil else {
            let code = lastError?.code ?? -1
            if code == -10877, retryOnInvalidElement {
                await stopRecognition()
                try? await Task.sleep(nanoseconds: 200_000_000)
                return try await startRecognition(locale: locale, retryOnInvalidElement: false)
            }
            throw SpeechRecognizerError.audioEngineFailed(code: code)
        }

        isRunning = true
        audioEngine = selectedEngine
        recognitionRequest = request

        return AsyncThrowingStream<String, Error> { continuation in
            self.continuation = continuation
            self.recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let result {
                    continuation.yield(result.bestTranscription.formattedString)
                    if result.isFinal {
                        continuation.finish()
                        return
                    }
                }

                if let error = error as NSError? {
                    print("Speech recognition error:", error.code, error.domain, error.localizedDescription)
                    continuation.finish(throwing: SpeechRecognizerError.recognitionFailed(code: error.code, domain: error.domain))
                }
            }
        }
    }

    public func stopRecognition() async {
        recognitionTask?.cancel()
        recognitionTask = nil

        if let engine = audioEngine {
            engine.stop()
        }
        audioEngine = nil
        stopCaptureSession()

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        continuation?.finish()
        continuation = nil
        isRunning = false
        cleanupTap()
    }

    private func requestMicrophoneAccess() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }

    private static func mapStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> SpeechRecognizerAuthorizationStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }

    private enum AudioCaptureStrategy: String {
        case captureSession
        case inputNodeFormat
        case inputNodeNilFormat
        case mixerNodeFormat
    }

    private func configureEngine(
        engine: AVAudioEngine,
        request: SFSpeechAudioBufferRecognitionRequest,
        bufferSize: AVAudioFrameCount,
        strategy: AudioCaptureStrategy
    ) throws {
        let inputNode = engine.inputNode
        let outputFormat = inputNode.outputFormat(forBus: 0)
        let inputFormat = inputNode.inputFormat(forBus: 0)
        print("Speech input format:", inputFormat)
        print("Speech output format:", outputFormat)

        let format = outputFormat.channelCount > 0 ? outputFormat : inputFormat
        if format.channelCount == 0 || format.sampleRate == 0 {
            throw SpeechRecognizerError.initializationFailed
        }

        switch strategy {
        case .inputNodeFormat:
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { buffer, _ in
                request.append(buffer)
            }
            tapNode = inputNode
            tapBus = 0
        case .inputNodeNilFormat:
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { buffer, _ in
                request.append(buffer)
            }
            tapNode = inputNode
            tapBus = 0
        case .mixerNodeFormat:
            let mixerNode = engine.mainMixerNode
            engine.connect(inputNode, to: mixerNode, format: format)
            mixerNode.outputVolume = 0
            let mixerFormat = mixerNode.outputFormat(forBus: 0)
            mixerNode.installTap(onBus: 0, bufferSize: bufferSize, format: mixerFormat) { buffer, _ in
                request.append(buffer)
            }
            tapNode = mixerNode
            tapBus = 0
        case .captureSession:
            return
        }

        engine.prepare()
        try engine.start()
    }

    private func cleanupTap() {
        if let node = tapNode, node.engine != nil {
            node.removeTap(onBus: tapBus)
        }
        tapNode = nil
        tapBus = 0
    }

    private func startCaptureSession(request: SFSpeechAudioBufferRecognitionRequest) throws {
        let session = AVCaptureSession()
        session.beginConfiguration()

        let device = AVCaptureDevice.default(.microphone, for: .audio, position: .unspecified)
            ?? AVCaptureDevice.default(for: .audio)
        guard let audioDevice = device else { throw SpeechRecognizerError.inputDeviceUnavailable }

        let input = try AVCaptureDeviceInput(device: audioDevice)
        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue(label: "SpeechRecognition.CaptureQueue")
        let delegate = CaptureOutputDelegate(request: request)
        output.setSampleBufferDelegate(delegate, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
        session.startRunning()

        captureSession = session
        captureDelegate = delegate
        captureQueue = queue
    }

    private func stopCaptureSession() {
        captureSession?.stopRunning()
        captureSession = nil
        captureDelegate = nil
        captureQueue = nil
    }
}

private final class CaptureOutputDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let request: SFSpeechAudioBufferRecognitionRequest

    init(request: SFSpeechAudioBufferRecognitionRequest) {
        self.request = request
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        request.appendAudioSampleBuffer(sampleBuffer)
    }
}
