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
                algorithmPicker
                syllableSelector
                storyPicker
                micStatus
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

    private var algorithmPicker: some View {
        Picker("Algoritmo", selection: $viewModel.algorithmSelection) {
            ForEach(ReadingAlgorithmOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("reading_algorithm_picker")
    }

    @ViewBuilder
    private var syllableSelector: some View {
        if viewModel.algorithmSelection == .syllableFilteredSpeech {
            Stepper(
                "Sílabas: \(viewModel.selectedSyllableCount)",
                value: $viewModel.selectedSyllableCount,
                in: 1...5
            )
            .accessibilityIdentifier("reading_syllable_stepper")
        }
    }

    private var storyPicker: some View {
        Picker("Historia", selection: $viewModel.selectedStory) {
            ForEach(viewModel.stories) { story in
                Text(story.title).tag(Optional(story))
            }
        }
        .pickerStyle(.menu)
    }

    private var micStatus: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let message = viewModel.speechErrorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .accessibilityIdentifier("reading_mic_status")
    }

    private var wordCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Texto actual")
                .font(.headline)
            if let message = viewModel.emptyStateMessage {
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                Text(viewModel.currentSegmentText ?? "—")
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
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("Iniciar") { Task { await viewModel.startSession() } }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.hasWords)
                .accessibilityIdentifier("reading_start_button")
            Button("Siguiente") { Task { await viewModel.nextWord() } }
                .buttonStyle(.bordered)
                .disabled(viewModel.state != .inProgress)
                .accessibilityIdentifier("reading_next_button")
            Button("Finalizar") { Task { await viewModel.finishSession() } }
                .buttonStyle(.bordered)
                .disabled(viewModel.state != .inProgress)
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

    private var statusText: String {
        switch viewModel.speechStatus {
        case .authorized:
            return "Micrófono: listo para escuchar"
        case .denied:
            return "Micrófono: permiso denegado"
        case .restricted:
            return "Micrófono: restringido"
        case .notDetermined:
            return "Micrófono: sin permiso todavía"
        }
    }

    private func format(_ value: TimeInterval) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}
