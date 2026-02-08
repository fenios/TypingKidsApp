import XCTest
@testable import TypingPractice
import Stories
import Persistence
import Core
import UserProgress

private final class FixedClock: Clock {
    private var times: [Date]
    init(times: [Date]) { self.times = times }
    func now() -> Date {
        guard !times.isEmpty else { return Date(timeIntervalSince1970: 0) }
        return times.removeFirst()
    }
}

private struct StubStoryRepository: StoryRepository, Sendable {
    let stories: [Story]
    func loadStories() async throws -> [Story] { stories }
}

private actor InMemoryResultsStore: UserResultsStore {
    private var typing: [UUID: [TypingResult]] = [:]
    private var reading: [UUID: [ReadingResult]] = [:]

    func saveTypingResult(_ result: TypingResult, for userId: UUID) async {
        var list = typing[userId] ?? []
        list.append(result)
        typing[userId] = list
    }

    func saveReadingResult(_ result: ReadingResult, for userId: UUID) async {
        var list = reading[userId] ?? []
        list.append(result)
        reading[userId] = list
    }

    func typingResults(for userId: UUID) async -> [TypingResult] { typing[userId] ?? [] }
    func readingResults(for userId: UUID) async -> [ReadingResult] { reading[userId] ?? [] }
    func typingResultsByUser() async -> [UUID : [TypingResult]] { typing }
    func readingResultsByUser() async -> [UUID : [ReadingResult]] { reading }
}

@MainActor
final class TypingPracticeViewModelTests: XCTestCase {
    func testFinishSessionStoresResult() async throws {
        let story = Story(id: UUID(), title: "Prueba", text: "hola", minAge: 7, maxAge: 10)
        let repo = StubStoryRepository(stories: [story])
        let resultsStore = InMemoryResultsStore()
        let userId = UUID()
        let clock = FixedClock(times: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
            Date(timeIntervalSince1970: 4),
            Date(timeIntervalSince1970: 4)
        ])
        let viewModel = TypingPracticeViewModel(storyRepository: repo, resultsStore: resultsStore, clock: clock, userId: userId)
        await viewModel.loadStories()
        await viewModel.startSession()
        viewModel.updateTypedText("hola")
        await viewModel.finishSession()

        let results = await resultsStore.typingResults(for: userId)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.metrics.errorCount, 0)
    }
}
