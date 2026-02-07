import XCTest
@testable import TypingPractice
import Stories
import Persistence
import Core

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

@MainActor
final class TypingPracticeViewModelTests: XCTestCase {
    func testFinishSessionStoresResult() async throws {
        let story = Story(id: UUID(), title: "Prueba", text: "hola", minAge: 7, maxAge: 10)
        let repo = StubStoryRepository(stories: [story])
        let store = InMemoryKeyValueStore()
        let clock = FixedClock(times: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
            Date(timeIntervalSince1970: 4),
            Date(timeIntervalSince1970: 4)
        ])
        let viewModel = TypingPracticeViewModel(storyRepository: repo, store: store, clock: clock)
        await viewModel.loadStories()
        await viewModel.startSession()
        viewModel.updateTypedText("hola")
        viewModel.finishSession()

        let results = try store.get([TypingResult].self, forKey: "typing_results")
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.metrics.errorCount, 0)
    }
}
