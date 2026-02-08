import Foundation
import Observation
import Core
import Stories
import UserProgress
import LanguageProcessing
import SpeechRecognition

@MainActor
@Observable
public final class ReadingPracticeViewModel {
    public private(set) var stories: [Story] = []
    public private(set) var state: ReadingSessionState = .idle
    public var selectedStory: Story? { didSet { resetForSelectionChange() } }
    public var algorithmSelection: ReadingAlgorithmOption = .sequentialStorySpeech { didSet { resetForSelectionChange() } }
    public var selectedSyllableCount: Int = 2 { didSet { if algorithmSelection == .syllableFilteredSpeech { resetForSelectionChange() } } }
    public private(set) var currentWordIndex: Int = 0
    public private(set) var speechStatus: SpeechRecognizerAuthorizationStatus = .notDetermined
    public private(set) var speechErrorMessage: String? = nil
    public private(set) var emptyStateMessage: String? = nil
    public private(set) var currentSegmentWordCount: Int = 1

    private let storyRepository: StoryRepository
    private let resultsStore: UserResultsStore
    private let clock: Clock
    private let speechRecognizer: SpeechRecognizer
    private let normalizer: TextNormalizer
    private let tokenizer: WordTokenizer
    private let syllableCounter: SpanishSyllableCounter
    private let adaptationConfig: ReadingAdaptationConfig
    private let adaptationStrategy: ReadingAdaptationStrategy
    private let userId: UUID

    private var displayWords: [String] = []
    private var normalizedWords: [String] = []
    private var wordStartTime: Date?
    private var wordTimings: [WordTiming] = []
    private var sessionStart: Date?
    private var recognitionTask: Task<Void, Never>?
    private var adaptiveController: AdaptiveWordCountController
    private var wordsSinceLastAdaptation: Int = 0
    private var pendingComprehensionScore: Double? = nil

    public init(
        storyRepository: StoryRepository,
        resultsStore: UserResultsStore,
        clock: Clock,
        userId: UUID,
        speechRecognizer: SpeechRecognizer,
        normalizer: TextNormalizer = TextNormalizer(),
        tokenizer: WordTokenizer = WordTokenizer(),
        syllableCounter: SpanishSyllableCounter = SpanishSyllableCounter(),
        adaptationConfig: ReadingAdaptationConfig = .forAges7To10(),
        adaptationStrategy: ReadingAdaptationStrategy = CombinedReadingAdaptationStrategy()
    ) {
        self.storyRepository = storyRepository
        self.resultsStore = resultsStore
        self.clock = clock
        self.userId = userId
        self.speechRecognizer = speechRecognizer
        self.normalizer = normalizer
        self.tokenizer = tokenizer
        self.syllableCounter = syllableCounter
        self.adaptationConfig = adaptationConfig
        self.adaptationStrategy = adaptationStrategy
        self.adaptiveController = AdaptiveWordCountController(config: adaptationConfig, strategy: adaptationStrategy)
        self.currentSegmentWordCount = adaptationConfig.initialWordCount
    }

    public var currentWord: String? {
        guard currentWordIndex < displayWords.count else { return nil }
        return displayWords[currentWordIndex]
    }

    public var currentSegmentText: String? {
        guard currentWordIndex < displayWords.count else { return nil }
        let end = min(currentWordIndex + currentSegmentWordCount, displayWords.count)
        let segment = displayWords[currentWordIndex..<end]
        return segment.joined(separator: " ")
    }

    public var hasWords: Bool {
        !displayWords.isEmpty
    }

    public func loadStories() async {
        let loaded = (try? await storyRepository.loadStories()) ?? []
        if loaded.isEmpty {
            let fallback = Story(id: UUID(), title: "Historia de ejemplo", text: "Hola. Este es un texto de ejemplo para practicar.", minAge: 7, maxAge: 10)
            stories = [fallback]
            selectedStory = fallback
            return
        }
        stories = loaded
        if selectedStory == nil {
            selectedStory = loaded.first
        }
    }

    public func startSession() async {
        await stopRecognition()
        if selectedStory == nil {
            let fallback = Story(id: UUID(), title: "Historia de ejemplo", text: "Hola. Este es un texto de ejemplo para practicar.", minAge: 7, maxAge: 10)
            stories = [fallback]
            selectedStory = fallback
            Task { await loadStories() }
        }

        rebuildWordList()
        guard hasWords else {
            state = .idle
            return
        }

        currentWordIndex = 0
        wordTimings = []
        adaptiveController.reset()
        currentSegmentWordCount = adaptiveController.wordCount
        wordsSinceLastAdaptation = 0
        sessionStart = clock.now()
        wordStartTime = clock.now()
        state = .inProgress

        speechErrorMessage = nil
        speechStatus = await speechRecognizer.requestAuthorization()
        guard speechStatus == .authorized else { return }

        do {
            let stream = try await speechRecognizer.startRecognition(locale: Locale(identifier: "es-ES"))
            recognitionTask = Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    for try await transcript in stream {
                        await self.handleTranscription(transcript)
                    }
                } catch let error as SpeechRecognizerError {
                    self.handleRecognitionError(error)
                } catch {
                    self.speechErrorMessage = "No se pudo iniciar el reconocimiento de voz."
                }
                await self.speechRecognizer.stopRecognition()
                self.recognitionTask = nil
            }
        } catch let error as SpeechRecognizerError {
            switch error {
            case .microphoneDenied:
                speechErrorMessage = "Micrófono bloqueado. Actívalo en Configuración del sistema."
            case .onDeviceNotSupported:
                speechErrorMessage = "Este dispositivo no soporta reconocimiento en el dispositivo."
            case .audioEngineFailed(let code):
                speechErrorMessage = "Error de audio (\(code)). Revisa el micrófono en Configuración del sistema."
            case .inputDeviceUnavailable:
                speechErrorMessage = "No se detecta ningún micrófono. Revisa tu configuración de entrada."
            case .initializationFailed:
                speechErrorMessage = "No se pudo inicializar el micrófono. Revisa el dispositivo de entrada."
            case .recognitionFailed(let code, let domain):
                if domain == "kLSRErrorDomain", code == 201 {
                    speechErrorMessage = "Siri y Dictado están desactivados. Actívalos en Configuración del sistema."
                } else {
                    speechErrorMessage = "Error de reconocimiento (\(code))."
                }
            default:
                speechErrorMessage = "No se pudo iniciar el reconocimiento de voz."
            }
        } catch {
            speechErrorMessage = "No se pudo iniciar el reconocimiento de voz."
        }
    }

    public func nextWord() async {
        await advanceWordIfPossible()
    }

    public func finishSession() async {
        guard let story = selectedStory, let startedAt = sessionStart else { return }
        let totalTime = clock.now().timeIntervalSince(startedAt)
        let metrics = ReadingMetrics(wordTimings: wordTimings, totalTime: totalTime)
        let result = ReadingResult(storyId: story.id, date: clock.now(), metrics: metrics)
        await resultsStore.saveReadingResult(result, for: userId)
        state = .finished(result)
        Task { await stopRecognition() }
    }

    public func resetSession() {
        state = .idle
        currentWordIndex = 0
        wordTimings = []
        sessionStart = nil
        wordStartTime = nil
        adaptiveController.reset()
        currentSegmentWordCount = adaptiveController.wordCount
        wordsSinceLastAdaptation = 0
        pendingComprehensionScore = nil
        Task { await stopRecognition() }
    }

    public func recordComprehensionScore(_ score: Double?) {
        guard let score else {
            pendingComprehensionScore = nil
            return
        }
        pendingComprehensionScore = min(max(score, 0), 1)
    }

    private func handleTranscription(_ transcript: String) async {
        guard state == .inProgress else { return }
        guard currentWordIndex < normalizedWords.count else { return }
        let normalizedTranscript = normalizer.normalize(transcript)
        print("Speech recognized:", transcript, "->", normalizedTranscript)
        let words = tokenizer.tokenize(normalizedTranscript)
        let expected = normalizedWords[currentWordIndex]
        if words.contains(expected) {
            await advanceWordIfPossible()
        }
    }

    private func handleRecognitionError(_ error: SpeechRecognizerError) {
        switch error {
        case .recognitionFailed(let code, let domain):
            if domain == "kLSRErrorDomain", code == 201 {
                speechErrorMessage = "Siri y Dictado están desactivados. Actívalos en Configuración del sistema."
            } else {
                speechErrorMessage = "Error de reconocimiento (\(code))."
            }
        default:
            speechErrorMessage = "No se pudo iniciar el reconocimiento de voz."
        }
    }

    private func advanceWordIfPossible() async {
        guard state == .inProgress else { return }
        guard currentWordIndex < normalizedWords.count else { return }
        let now = clock.now()
        if let start = wordStartTime {
            let word = displayWords[currentWordIndex]
            wordTimings.append(WordTiming(word: word, duration: now.timeIntervalSince(start)))
        }
        currentWordIndex += 1
        wordStartTime = now
        wordsSinceLastAdaptation += 1
        updateAdaptiveSegmentIfNeeded()
        if currentWordIndex >= normalizedWords.count {
            await finishSession()
        }
    }

    private func updateAdaptiveSegmentIfNeeded() {
        guard wordsSinceLastAdaptation >= currentSegmentWordCount else { return }
        let recentCount = min(wordsSinceLastAdaptation, wordTimings.count)
        guard recentCount > 0 else { return }

        let recentTimings = Array(wordTimings.suffix(recentCount))
        let sample = ReadingPerformanceSample.fromWordTimings(recentTimings, comprehensionScore: pendingComprehensionScore)
        pendingComprehensionScore = nil

        currentSegmentWordCount = adaptiveController.register(sample: sample)
        wordsSinceLastAdaptation = 0
    }

    private func rebuildWordList() {
        guard let story = selectedStory else {
            displayWords = []
            normalizedWords = []
            emptyStateMessage = nil
            return
        }

        let tokens = tokenizer.tokenize(story.text)
        let pairs = tokens.map { (display: $0, normalized: normalizer.normalize($0)) }
            .filter { !$0.normalized.isEmpty }

        let filtered: [(display: String, normalized: String)]
        switch algorithmSelection {
        case .sequentialStorySpeech:
            filtered = pairs
        case .syllableFilteredSpeech:
            filtered = pairs.filter { syllableCounter.countSyllables(in: $0.normalized) == selectedSyllableCount }
        }

        displayWords = filtered.map { $0.display }
        normalizedWords = filtered.map { $0.normalized }
        currentWordIndex = 0
        adaptiveController.reset()
        currentSegmentWordCount = adaptiveController.wordCount
        wordsSinceLastAdaptation = 0
        if displayWords.isEmpty {
            switch algorithmSelection {
            case .sequentialStorySpeech:
                emptyStateMessage = "No hay palabras en esta historia."
            case .syllableFilteredSpeech:
                emptyStateMessage = "No hay palabras con \(selectedSyllableCount) sílabas en esta historia."
            }
        } else {
            emptyStateMessage = nil
        }
    }

    private func resetForSelectionChange() {
        if case .inProgress = state {
            resetSession()
        }
        rebuildWordList()
    }

    private func stopRecognition() async {
        recognitionTask?.cancel()
        recognitionTask = nil
        await speechRecognizer.stopRecognition()
    }

    #if DEBUG
    /// Example usage with sample inputs for unit testing or playground-style validation.
    public static func exampleAdaptiveUsage() -> [Int] {
        var controller = AdaptiveWordCountController(config: .forAges7To10())
        let samples: [ReadingPerformanceSample] = [
            .init(wpm: 55, varianceSeconds: 0.22, comprehensionScore: 0.9),
            .init(wpm: 65, varianceSeconds: 0.16, comprehensionScore: 0.85),
            .init(wpm: 75, varianceSeconds: 0.12, comprehensionScore: 0.8),
            .init(wpm: 90, varianceSeconds: 0.1, comprehensionScore: 0.9)
        ]
        return samples.map { controller.register(sample: $0) }
    }
    #endif
}
