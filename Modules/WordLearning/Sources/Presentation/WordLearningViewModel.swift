import Foundation
import Observation
import AppKit
import Clipart

public enum ClipartImageState {
    case idle
    case loading
    case loaded(NSImage)
    case failed(String)
}

@MainActor
@Observable
public final class WordLearningViewModel {
    public private(set) var words: [VocabularyWord] = []
    public private(set) var imageState: ClipartImageState = .idle
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil
    public private(set) var currentIndex: Int = 0

    private let repository: VocabularyRepository
    private let imageLoader: ClipartImageLoading
    private var imageTask: Task<Void, Never>?

    public init(repository: VocabularyRepository, imageLoader: ClipartImageLoading) {
        self.repository = repository
        self.imageLoader = imageLoader
    }

    public var currentWord: VocabularyWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    public func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let loadedWords = try await repository.loadWords()
            words = loadedWords
            currentIndex = 0
            isLoading = false
            imageTask?.cancel()
            await loadImageForCurrentWord()
        } catch {
            isLoading = false
            errorMessage = "No se pudieron cargar las palabras."
            words = []
            imageState = .idle
        }
    }

    public func nextWord() {
        guard !words.isEmpty else { return }
        currentIndex = (currentIndex + 1) % words.count
        imageTask?.cancel()
        imageTask = Task { await loadImageForCurrentWord() }
    }

    public func retryImage() {
        imageTask?.cancel()
        imageTask = Task { await loadImageForCurrentWord() }
    }

    private func loadImageForCurrentWord() async {
        guard let word = currentWord else {
            imageState = .idle
            return
        }

        imageState = .loading
        let url = word.imageURL
        do {
            let image = try await imageLoader.loadImage(from: url)
            guard !Task.isCancelled else { return }
            imageState = .loaded(image)
        } catch {
            imageState = .failed("No se pudo cargar la imagen.")
        }
    }
}
