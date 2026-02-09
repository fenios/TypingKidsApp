import SwiftUI
import Observation
import AccessibilitySettings

public struct WordLearningView: View {
    @Bindable private var viewModel: WordLearningViewModel
    @Bindable private var settingsViewModel: AccessibilitySettingsViewModel

    public init(viewModel: WordLearningViewModel, settingsViewModel: AccessibilitySettingsViewModel) {
        self.viewModel = viewModel
        self.settingsViewModel = settingsViewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                header
                content
                actionBar
                Spacer(minLength: 8)
            }
            .padding()
            .navigationTitle("Vocabulario")
            .task { await viewModel.load() }
        }
        .accessibilityIdentifier("word_learning_view")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Aprende palabras con imágenes")
                .font(.title2)
                .bold()
            Text("Observa la imagen y lee la palabra en voz alta.")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Cargando palabras...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView(
                "Sin palabras",
                systemImage: "text.badge.xmark",
                description: Text(error)
            )
            .frame(maxWidth: .infinity, minHeight: 260)
        } else if let word = viewModel.currentWord {
            wordCard(word)
        } else {
            ContentUnavailableView(
                "Sin palabras",
                systemImage: "text.badge.xmark",
                description: Text("Agrega palabras para empezar.")
            )
            .frame(maxWidth: .infinity, minHeight: 260)
        }
    }

    private func wordCard(_ word: VocabularyWord) -> some View {
        VStack(alignment: .center, spacing: 16) {
            imageSection
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(settingsViewModel.settings.highContrast ? Color.black : Color.white)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
                )

            Text(word.word)
                .font(.system(size: 36 * settingsViewModel.settings.fontScale, weight: .bold))
                .accessibilityIdentifier("word_learning_word_label")

            Text("Fuente: \(word.source)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(.windowBackgroundColor), Color(.windowBackgroundColor).opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var imageSection: some View {
        switch viewModel.imageState {
        case .idle:
            placeholder
        case .loading:
            ProgressView("Cargando imagen...")
                .accessibilityIdentifier("word_learning_image_loading")
        case .loaded(let image):
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .padding(16)
                .accessibilityIdentifier("word_learning_image")
        case .failed(let message):
            VStack(spacing: 8) {
                placeholder
                Text(message)
                    .foregroundStyle(.secondary)
                Button("Reintentar") { viewModel.retryImage() }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("word_learning_retry_button")
            }
        }
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
    }

    private var actionBar: some View {
        HStack {
            Spacer()
            Button("Siguiente") { viewModel.nextWord() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("word_learning_next_button")
        }
    }
}
