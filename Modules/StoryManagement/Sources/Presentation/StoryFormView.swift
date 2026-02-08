import SwiftUI

public struct StoryFormView: View {
    let title: String
    let initialDraft: StoryDraft
    let onSave: (StoryDraft) async -> StoryFormError?

    @Environment(\.dismiss) private var dismiss
    @State private var draft: StoryDraft
    @State private var errorMessage: String? = nil

    public init(
        title: String,
        initialDraft: StoryDraft,
        onSave: @escaping (StoryDraft) async -> StoryFormError?
    ) {
        self.title = title
        self.initialDraft = initialDraft
        self.onSave = onSave
        _draft = State(initialValue: initialDraft)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Título", text: $draft.title)
                    TextEditor(text: $draft.text)
                        .frame(minHeight: 160)
                }

                Section("Edad recomendada") {
                    Stepper("Mínima: \(draft.minAge)", value: $draft.minAge, in: 5...12)
                    Stepper("Máxima: \(draft.maxAge)", value: $draft.maxAge, in: 5...12)
                }

                if let message = errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Guardar") {
                        Task {
                            let result = await onSave(draft)
                            if let error = result {
                                errorMessage = error.localizedDescription
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 500)
    }
}
