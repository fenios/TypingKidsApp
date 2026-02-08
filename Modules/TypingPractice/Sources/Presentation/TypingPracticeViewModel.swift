import Foundation
import Observation
import Core
import Stories
import UserProgress

@MainActor
@Observable
public final class TypingPracticeViewModel {
    public private(set) var stories: [Story] = []
    public private(set) var state: TypingSessionState = .idle
    public var selectedStory: Story? = nil
    public var typedText: String = ""

    private let storyRepository: StoryRepository
    private let resultsStore: UserResultsStore
    private let clock: Clock
    private let evaluator: TypingEvaluator
    private let userId: UUID

    private var sessionStart: Date?
    private var firstKeyTime: Date?

    public init(
        storyRepository: StoryRepository,
        resultsStore: UserResultsStore,
        clock: Clock,
        userId: UUID,
        evaluator: TypingEvaluator = TypingEvaluator()
    ) {
        self.storyRepository = storyRepository
        self.resultsStore = resultsStore
        self.clock = clock
        self.userId = userId
        self.evaluator = evaluator
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
        if selectedStory == nil {
            let fallback = Story(id: UUID(), title: "Historia de ejemplo", text: "Hola. Este es un texto de ejemplo para practicar.", minAge: 7, maxAge: 10)
            stories = [fallback]
            selectedStory = fallback
            Task { await loadStories() }
        }
        guard selectedStory != nil else { return }
        typedText = ""
        sessionStart = clock.now()
        firstKeyTime = nil
        state = .inProgress
    }

    public func updateTypedText(_ newValue: String) {
        let sanitized = SpanishISOKeyboard.sanitizeInput(newValue)
        if sanitized != typedText {
            typedText = sanitized
        }
        if firstKeyTime == nil, !typedText.isEmpty {
            firstKeyTime = clock.now()
        }
    }

    public func finishSession() async {
        guard let story = selectedStory, let startedAt = sessionStart else { return }
        let metrics = evaluator.evaluate(
            target: story.text,
            typed: typedText,
            startedAt: startedAt,
            firstKeyAt: firstKeyTime,
            endedAt: clock.now()
        )
        let result = TypingResult(storyId: story.id, date: clock.now(), metrics: metrics)
        await resultsStore.saveTypingResult(result, for: userId)
        state = .finished(result)
    }
}
