import Foundation
import Observation
import Core
import Stories
import Persistence
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

    private let storyRepository: StoryRepository
    private let store: KeyValueStore
    private let clock: Clock
    private let speechRecognizer: SpeechRecognizer
    private let normalizer: TextNormalizer
    private let tokenizer: WordTokenizer
    private let syllableCounter: SpanishSyllableCounter
    private let resultsKey = "reading_results"

    private var displayWords: [String] = []
    private var normalizedWords: [String] = []
    private var wordStartTime: Date?
    private var wordTimings: [WordTiming] = []
    private var sessionStart: Date?
    private var recognitionTask: Task<Void, Never>?

    public init(
        storyRepository: StoryRepository,
        store: KeyValueStore,
        clock: Clock,
        speechRecognizer: SpeechRecognizer,
        normalizer: TextNormalizer = TextNormalizer(),
        tokenizer: WordTokenizer = WordTokenizer(),
        syllableCounter: SpanishSyllableCounter = SpanishSyllableCounter()
    ) {
        self.storyRepository = storyRepository
        self.store = store
        self.clock = clock
        self.speechRecognizer = speechRecognizer
        self.normalizer = normalizer
        self.tokenizer = tokenizer
        self.syllableCounter = syllableCounter
    }

    public var currentWord: String? {
        guard currentWordIndex < displayWords.count else { return nil }
        return displayWords[currentWordIndex]
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

    public func nextWord() {
        advanceWordIfPossible()
    }

    public func finishSession() {
        guard let story = selectedStory, let startedAt = sessionStart else { return }
        let totalTime = clock.now().timeIntervalSince(startedAt)
        let metrics = ReadingMetrics(wordTimings: wordTimings, totalTime: totalTime)
        let result = ReadingResult(storyId: story.id, date: clock.now(), metrics: metrics)
        saveResult(result)
        state = .finished(result)
        Task { await stopRecognition() }
    }

    public func resetSession() {
        state = .idle
        currentWordIndex = 0
        wordTimings = []
        sessionStart = nil
        wordStartTime = nil
        Task { await stopRecognition() }
    }

    private func handleTranscription(_ transcript: String) async {
        guard state == .inProgress else { return }
        guard currentWordIndex < normalizedWords.count else { return }
        let normalizedTranscript = normalizer.normalize(transcript)
        print("Speech recognized:", transcript, "->", normalizedTranscript)
        let words = tokenizer.tokenize(normalizedTranscript)
        let expected = normalizedWords[currentWordIndex]
        if words.contains(expected) {
            advanceWordIfPossible()
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

    private func advanceWordIfPossible() {
        guard state == .inProgress else { return }
        guard currentWordIndex < normalizedWords.count else { return }
        let now = clock.now()
        if let start = wordStartTime {
            let word = displayWords[currentWordIndex]
            wordTimings.append(WordTiming(word: word, duration: now.timeIntervalSince(start)))
        }
        currentWordIndex += 1
        wordStartTime = now
        if currentWordIndex >= normalizedWords.count {
            finishSession()
        }
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

    private func saveResult(_ result: ReadingResult) {
        let existing = (try? store.get([ReadingResult].self, forKey: resultsKey)) ?? []
        var updated = existing
        updated.append(result)
        try? store.set(updated, forKey: resultsKey)
    }

    private func stopRecognition() async {
        recognitionTask?.cancel()
        recognitionTask = nil
        await speechRecognizer.stopRecognition()
    }
}
