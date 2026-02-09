import XCTest
import AppKit
@testable import WordLearning
import Clipart

@MainActor
final class WordLearningViewModelTests: XCTestCase {
    func testLoadSetsFirstWordAndLoadsImage() async {
        let repository = TestVocabularyRepository(words: [
            VocabularyWord(word: "Casa", imageURL: URL(string: "https://example.com/casa.png")!, source: "Test")
        ])
        let loader = TestImageLoader()
        let viewModel = WordLearningViewModel(repository: repository, imageLoader: loader)

        await viewModel.load()

        XCTAssertEqual(viewModel.currentWord?.word, "Casa")
        switch viewModel.imageState {
        case .loaded:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected image to be loaded")
        }
    }

    func testNextWordCyclesThroughList() async {
        let repository = TestVocabularyRepository(words: [
            VocabularyWord(word: "Casa", imageURL: URL(string: "https://example.com/casa.png")!, source: "Test"),
            VocabularyWord(word: "Reloj", imageURL: URL(string: "https://example.com/reloj.png")!, source: "Test")
        ])
        let loader = TestImageLoader()
        let viewModel = WordLearningViewModel(repository: repository, imageLoader: loader)

        await viewModel.load()
        viewModel.nextWord()

        XCTAssertEqual(viewModel.currentWord?.word, "Reloj")
    }
}

private struct TestVocabularyRepository: VocabularyRepository {
    let words: [VocabularyWord]

    func loadWords() async throws -> [VocabularyWord] {
        words
    }
}

@MainActor
private final class TestImageLoader: ClipartImageLoading {
    func loadImage(from url: URL) async throws -> NSImage {
        NSImage(size: NSSize(width: 10, height: 10))
    }
}
