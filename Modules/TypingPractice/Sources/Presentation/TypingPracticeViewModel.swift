import Foundation
import Observation
import Core
import Stories
import Persistence

@MainActor
@Observable
public final class TypingPracticeViewModel {
    public private(set) var stories: [Story] = []
    public private(set) var state: TypingSessionState = .idle
    public var selectedStory: Story? = nil
    public var typedText: String = ""

    private let storyRepository: StoryRepository
    private let store: KeyValueStore
    private let clock: Clock
    private let evaluator: TypingEvaluator
    private let resultsKey = "typing_results"

    private var sessionStart: Date?
    private var firstKeyTime: Date?

    public init(
        storyRepository: StoryRepository,
        store: KeyValueStore,
        clock: Clock,
        evaluator: TypingEvaluator = TypingEvaluator()
    ) {
        self.storyRepository = storyRepository
        self.store = store
        self.clock = clock
        self.evaluator = evaluator
    }

    public func loadStories() {
        stories = (try? storyRepository.loadStories()) ?? []
        if selectedStory == nil {
            selectedStory = stories.first
        }
    }

    public func startSession() {
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

    public func finishSession() {
        guard let story = selectedStory, let startedAt = sessionStart else { return }
        let metrics = evaluator.evaluate(
            target: story.text,
            typed: typedText,
            startedAt: startedAt,
            firstKeyAt: firstKeyTime,
            endedAt: clock.now()
        )
        let result = TypingResult(storyId: story.id, date: clock.now(), metrics: metrics)
        saveResult(result)
        state = .finished(result)
    }

    private func saveResult(_ result: TypingResult) {
        let existing = (try? store.get([TypingResult].self, forKey: resultsKey)) ?? []
        var updated = existing
        updated.append(result)
        try? store.set(updated, forKey: resultsKey)
    }
}
