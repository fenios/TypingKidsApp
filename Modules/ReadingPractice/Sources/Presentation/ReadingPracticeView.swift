import SwiftUI
import Observation
import AccessibilitySettings

public struct ReadingPracticeView: View {
    @Bindable private var viewModel: ReadingPracticeViewModel
    @Bindable private var settingsViewModel: AccessibilitySettingsViewModel

    public init(viewModel: ReadingPracticeViewModel, settingsViewModel: AccessibilitySettingsViewModel) {
        self.viewModel = viewModel
        self.settingsViewModel = settingsViewModel
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                storyPicker
                wordCard
                actionBar
                resultSummary
                Spacer(minLength: 8)
            }
            .padding()
            .task { await viewModel.loadStories() }
            .navigationTitle("Práctica de lectura")
        }
        .accessibilityIdentifier("reading_practice_view")
    }

    private var storyPicker: some View {
        Picker("Historia", selection: $viewModel.selectedStory) {
            ForEach(viewModel.stories) { story in
                Text(story.title).tag(Optional(story))
            }
        }
        .pickerStyle(.menu)
    }

    private var wordCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Palabra actual")
                .font(.headline)
            Text(viewModel.currentWord ?? "—")
                .font(.system(size: 28 * settingsViewModel.settings.fontScale, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(settingsViewModel.settings.highContrast ? Color.black : Color.white)
                .foregroundStyle(settingsViewModel.settings.highContrast ? .white : .primary)
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
                )
                .accessibilityIdentifier("reading_current_word")
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("Iniciar") { Task { await viewModel.startSession() } }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("reading_start_button")
            Button("Siguiente") { viewModel.nextWord() }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("reading_next_button")
            Button("Finalizar") { viewModel.finishSession() }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("reading_finish_button")
        }
    }

    private var resultSummary: some View {
        Group {
            if case let .finished(result) = viewModel.state {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Resultados")
                        .font(.headline)
                        .accessibilityIdentifier("reading_results_label")
                    Text("Tiempo total: \(format(result.metrics.totalTime))")
                    Text("Promedio por palabra: \(format(result.metrics.averageWordTime))")
                }
                .padding(.top, 8)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("reading_results")
            }
        }
    }

    private func format(_ value: TimeInterval) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}
