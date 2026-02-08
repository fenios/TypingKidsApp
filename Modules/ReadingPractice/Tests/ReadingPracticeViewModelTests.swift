import XCTest
@testable import ReadingPractice
import Stories
import Persistence
import Core
import UserProgress
import SpeechRecognition

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
final class ReadingPracticeViewModelTests: XCTestCase {
    func testSequentialSpeechAutoAdvancesAndSaves() async throws {
        let story = Story(id: UUID(), title: "Prueba", text: "hola mundo", minAge: 7, maxAge: 10)
        let repo = StubStoryRepository(stories: [story])
        let resultsStore = InMemoryResultsStore()
        let userId = UUID()
        let clock = FixedClock(times: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
            Date(timeIntervalSince1970: 2),
            Date(timeIntervalSince1970: 3),
            Date(timeIntervalSince1970: 3)
        ])
        let recognizer = SpeechRecognizerMock()

        let viewModel = ReadingPracticeViewModel(
            storyRepository: repo,
            resultsStore: resultsStore,
            clock: clock,
            userId: userId,
            speechRecognizer: recognizer
        )

        await viewModel.loadStories()
        await viewModel.startSession()

        await recognizer.push(transcript: "hola")
        await Task.yield()
        await recognizer.push(transcript: "mundo")
        await Task.yield()

        let results = await resultsStore.readingResults(for: userId)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.metrics.wordTimings.count, 2)
    }

    func testSyllableFilteredAlgorithmUsesSelectedCount() async {
        let story = Story(id: UUID(), title: "Prueba", text: "sol casa perro", minAge: 7, maxAge: 10)
        let repo = StubStoryRepository(stories: [story])
        let resultsStore = InMemoryResultsStore()
        let userId = UUID()
        let clock = FixedClock(times: [Date(timeIntervalSince1970: 0)])
        let recognizer = SpeechRecognizerMock()

        let viewModel = ReadingPracticeViewModel(
            storyRepository: repo,
            resultsStore: resultsStore,
            clock: clock,
            userId: userId,
            speechRecognizer: recognizer
        )

        await viewModel.loadStories()
        viewModel.algorithmSelection = .syllableFilteredSpeech
        viewModel.selectedSyllableCount = 1

        XCTAssertEqual(viewModel.currentWord, "sol")
    }

    func testDeniedAuthorizationKeepsManualAdvance() async throws {
        let story = Story(id: UUID(), title: "Prueba", text: "hola mundo", minAge: 7, maxAge: 10)
        let repo = StubStoryRepository(stories: [story])
        let resultsStore = InMemoryResultsStore()
        let userId = UUID()
        let clock = FixedClock(times: [
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 0),
            Date(timeIntervalSince1970: 1),
            Date(timeIntervalSince1970: 2),
            Date(timeIntervalSince1970: 3),
            Date(timeIntervalSince1970: 3)
        ])
        let recognizer = SpeechRecognizerMock(authorizationStatus: .denied)

        let viewModel = ReadingPracticeViewModel(
            storyRepository: repo,
            resultsStore: resultsStore,
            clock: clock,
            userId: userId,
            speechRecognizer: recognizer
        )

        await viewModel.loadStories()
        await viewModel.startSession()
        await viewModel.nextWord()
        await viewModel.nextWord()

        XCTAssertEqual(viewModel.speechStatus, .denied)
        let results = await resultsStore.readingResults(for: userId)
        XCTAssertEqual(results.count, 1)
    }
}
