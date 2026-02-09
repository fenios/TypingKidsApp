import SwiftUI
import AccessibilitySettings
import Clipart

#Preview {
    let repository = PreviewVocabularyRepository()
    let loader = ClipartImageLoaderMock(image: NSImage(systemSymbolName: "book", accessibilityDescription: nil) ?? NSImage())
    let viewModel = WordLearningViewModel(repository: repository, imageLoader: loader)
    let settings = AccessibilitySettingsViewModel(repository: PreviewAccessibilitySettingsRepository())
    WordLearningView(viewModel: viewModel, settingsViewModel: settings)
        .task { await viewModel.load() }
}

private struct PreviewVocabularyRepository: VocabularyRepository {
    func loadWords() async throws -> [VocabularyWord] {
        [
            VocabularyWord(
                word: "Casa",
                imageURL: URL(string: "https://openclipart.org/image/800px/svg_to_png/166549/simplehut.png")!,
                source: "OpenClipart"
            )
        ]
    }
}
