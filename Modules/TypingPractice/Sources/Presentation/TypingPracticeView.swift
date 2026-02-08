import SwiftUI
import Observation
import Stories
import AccessibilitySettings

public struct TypingPracticeView: View {
    @Bindable private var viewModel: TypingPracticeViewModel
    @Bindable private var settingsViewModel: AccessibilitySettingsViewModel

    public init(viewModel: TypingPracticeViewModel, settingsViewModel: AccessibilitySettingsViewModel) {
        self.viewModel = viewModel
        self.settingsViewModel = settingsViewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                storyPicker
                storyCard
                typingEditor
                actionBar
                resultSummary
                Spacer(minLength: 8)
            }
            .padding()
            .task { await viewModel.loadStories() }
            .navigationTitle("Práctica de escritura")
        }
        .accessibilityIdentifier("typing_practice_view")
    }

    private var storyPicker: some View {
        Picker("Historia", selection: $viewModel.selectedStory) {
            ForEach(viewModel.stories) { story in
                Text(story.title).tag(Optional(story))
            }
        }
        .pickerStyle(.menu)
    }

    private var storyCard: some View {
        Group {
            if let story = viewModel.selectedStory {
                Text(story.text)
                    .font(.system(size: 16 * settingsViewModel.settings.fontScale))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(settingsViewModel.settings.highContrast ? Color.black : Color.white)
                    .foregroundStyle(settingsViewModel.settings.highContrast ? .white : .primary)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
                    )
                    .accessibilityIdentifier("story_text")
            } else {
                Text("No hay historias disponibles")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var typingEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Escribe la historia aquí")
                .font(.headline)
            TextEditor(text: Binding(
                get: { viewModel.typedText },
                set: { viewModel.updateTypedText($0) }
            ))
            .font(.system(size: 16 * settingsViewModel.settings.fontScale))
            .frame(minHeight: 140)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
            )
            .accessibilityIdentifier("typing_text_editor")
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("Iniciar") { Task { await viewModel.startSession() } }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("typing_start_button")
            Button("Finalizar") { Task { await viewModel.finishSession() } }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("typing_finish_button")
        }
    }

    private var resultSummary: some View {
        Group {
            if case let .finished(result) = viewModel.state {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Resultados")
                        .font(.headline)
                        .accessibilityIdentifier("typing_results_label")
                    Text("Tiempo de reacción: \(format(result.metrics.reactionTime))")
                    Text("Tiempo total: \(format(result.metrics.totalTime))")
                    Text("Errores: \(result.metrics.errorCount)")
                }
                .padding(.top, 8)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("typing_results")
            }
        }
    }

    private func format(_ value: TimeInterval) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}
