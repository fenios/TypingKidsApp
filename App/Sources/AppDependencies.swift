import Foundation
import Core
import Persistence
import Stories
import TypingPractice
import ReadingPractice
import AccessibilitySettings
import SpeechRecognition
import LanguageProcessing
import UserManagement
import UserProgress
import Statistics

@MainActor
struct AppDependencies {
    let store: KeyValueStore
    let storyRepository: StoryRepository
    let clock: Clock
    let normalizer: TextNormalizer
    let tokenizer: WordTokenizer
    let syllableCounter: SpanishSyllableCounter
    let speechRecognizer: SpeechRecognizer
    let settingsRepository: DefaultAccessibilitySettingsRepository
    let userRepository: UserRepository
    let sessionRepository: UserSessionRepository
    let resultsStore: UserResultsStore

    init() {
        let useInMemory = ProcessInfo.processInfo.environment["USE_IN_MEMORY_STORE"] == "1"
        if useInMemory {
            store = InMemoryKeyValueStore()
        } else {
            store = (try? FileKeyValueStore(appIdentifier: "com.typingkids.app")) as KeyValueStore? ?? InMemoryKeyValueStore()
        }

        storyRepository = LocalStoryRepository()
        clock = SystemClock()
        normalizer = TextNormalizer()
        tokenizer = WordTokenizer()
        syllableCounter = SpanishSyllableCounter()
        speechRecognizer = Self.makeSpeechRecognizer()

        settingsRepository = DefaultAccessibilitySettingsRepository(store: store)
        userRepository = DefaultUserRepository(store: store)
        sessionRepository = DefaultUserSessionRepository(store: store)
        resultsStore = DefaultUserResultsStore(store: store)
    }

    func makeSettingsViewModel() -> AccessibilitySettingsViewModel {
        AccessibilitySettingsViewModel(repository: settingsRepository)
    }

    func makeTypingViewModel(userId: UUID) -> TypingPracticeViewModel {
        TypingPracticeViewModel(
            storyRepository: storyRepository,
            resultsStore: resultsStore,
            clock: clock,
            userId: userId
        )
    }

    func makeReadingViewModel(userId: UUID) -> ReadingPracticeViewModel {
        ReadingPracticeViewModel(
            storyRepository: storyRepository,
            resultsStore: resultsStore,
            clock: clock,
            userId: userId,
            speechRecognizer: speechRecognizer,
            normalizer: normalizer,
            tokenizer: tokenizer,
            syllableCounter: syllableCounter
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(userRepository: userRepository, sessionRepository: sessionRepository)
    }

    func makeCreateUserViewModel() -> CreateUserViewModel {
        CreateUserViewModel(userRepository: userRepository, sessionRepository: sessionRepository)
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(userRepository: userRepository, resultsStore: resultsStore)
    }

    private static func makeSpeechRecognizer() -> SpeechRecognizer {
        if ProcessInfo.processInfo.environment["USE_SPEECH_MOCK"] == "1" {
            return SpeechRecognizerMock()
        }
        return SystemSpeechRecognizer()
    }
}
