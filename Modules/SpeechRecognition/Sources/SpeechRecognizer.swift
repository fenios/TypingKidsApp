import Foundation

public enum SpeechRecognizerAuthorizationStatus: Sendable, Equatable {
    case authorized
    case denied
    case restricted
    case notDetermined
}

public enum SpeechRecognizerError: Error, Equatable {
    case unavailable
    case microphoneDenied
    case inputDeviceUnavailable
    case onDeviceNotSupported
    case initializationFailed
    case audioEngineFailed(code: Int)
    case recognitionFailed(code: Int, domain: String)
    case alreadyRunning
}

public protocol SpeechRecognizer: Sendable {
    func requestAuthorization() async -> SpeechRecognizerAuthorizationStatus
    func startRecognition(locale: Locale) async throws -> AsyncThrowingStream<String, Error>
    func stopRecognition() async
}
