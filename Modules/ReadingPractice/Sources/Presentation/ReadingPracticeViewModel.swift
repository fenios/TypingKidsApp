import Foundation
import Observation
import Core
import Stories
import Persistence

@MainActor
@Observable
public final class ReadingPracticeViewModel {
    public private(set) var stories: [Story] = []
    public private(set) var state: ReadingSessionState = .idle
    public var selectedStory: Story? = nil
    public private(set) var currentWordIndex: Int = 0

    private let storyRepository: StoryRepository
    private let store: KeyValueStore
    private let clock: Clock
    private let resultsKey = "reading_results"

    private var wordStartTime: Date?
    private var wordTimings: [WordTiming] = []
    private var sessionStart: Date?

    public init(storyRepository: StoryRepository, store: KeyValueStore, clock: Clock) {
        self.storyRepository = storyRepository
        self.store = store
        self.clock = clock
    }

    public func loadStories() {
        stories = (try? storyRepository.loadStories()) ?? []
        if selectedStory == nil {
            selectedStory = stories.first
        }
    }

    public func startSession() {
        guard selectedStory != nil else { return }
        currentWordIndex = 0
        wordTimings = []
        sessionStart = clock.now()
        wordStartTime = clock.now()
        state = .inProgress
    }

    public func nextWord() {
        guard let story = selectedStory else { return }
        guard currentWordIndex < story.words.count else { return }
        let word = story.words[currentWordIndex]
        let now = clock.now()
        if let start = wordStartTime {
            wordTimings.append(WordTiming(word: word, duration: now.timeIntervalSince(start)))
        }
        currentWordIndex += 1
        wordStartTime = now
        if currentWordIndex >= story.words.count {
            finishSession()
        }
    }

    public func finishSession() {
        guard let story = selectedStory, let startedAt = sessionStart else { return }
        let totalTime = clock.now().timeIntervalSince(startedAt)
        let metrics = ReadingMetrics(wordTimings: wordTimings, totalTime: totalTime)
        let result = ReadingResult(storyId: story.id, date: clock.now(), metrics: metrics)
        saveResult(result)
        state = .finished(result)
    }

    public var currentWord: String? {
        guard let story = selectedStory else { return nil }
        guard currentWordIndex < story.words.count else { return nil }
        return story.words[currentWordIndex]
    }

    private func saveResult(_ result: ReadingResult) {
        let existing = (try? store.get([ReadingResult].self, forKey: resultsKey)) ?? []
        var updated = existing
        updated.append(result)
        try? store.set(updated, forKey: resultsKey)
    }
}
