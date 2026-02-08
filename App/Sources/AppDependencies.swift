import Foundation
import Core
import Persistence
import Stories
import TypingPractice
import ReadingPractice
import AccessibilitySettings
import SpeechRecognition
import LanguageProcessing

@MainActor
struct AppDependencies {
    let settingsViewModel: AccessibilitySettingsViewModel
    let typingViewModel: TypingPracticeViewModel
    let readingViewModel: ReadingPracticeViewModel

    init() {
        let store: KeyValueStore = (try? FileKeyValueStore(appIdentifier: "com.typingkids.app")) as KeyValueStore? ?? InMemoryKeyValueStore()
        let storyRepository = LocalStoryRepository()
        let clock = SystemClock()
        let normalizer = TextNormalizer()
        let tokenizer = WordTokenizer()
        let syllableCounter = SpanishSyllableCounter()
        let speechRecognizer: SpeechRecognizer = Self.makeSpeechRecognizer()

        let settingsRepository = DefaultAccessibilitySettingsRepository(store: store)
        let settingsViewModel = AccessibilitySettingsViewModel(repository: settingsRepository)

        self.settingsViewModel = settingsViewModel
        self.typingViewModel = TypingPracticeViewModel(
            storyRepository: storyRepository,
            store: store,
            clock: clock
        )
        self.readingViewModel = ReadingPracticeViewModel(
            storyRepository: storyRepository,
            store: store,
            clock: clock,
            speechRecognizer: speechRecognizer,
            normalizer: normalizer,
            tokenizer: tokenizer,
            syllableCounter: syllableCounter
        )
    }

    private static func makeSpeechRecognizer() -> SpeechRecognizer {
        if ProcessInfo.processInfo.environment["USE_SPEECH_MOCK"] == "1" {
            return SpeechRecognizerMock()
        }
        return SystemSpeechRecognizer()
    }
}
