import SwiftUI
import Observation
import Stories

public struct StoryManagementView: View {
    @Bindable private var viewModel: StoryManagementViewModel
    @State private var activeSheet: ActiveSheet? = nil

    public init(viewModel: StoryManagementViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Historias")
                .toolbar { toolbarContent }
        }
        .task { await viewModel.loadStories() }
        .sheet(item: $activeSheet) { sheet in
            StoryFormView(
                title: sheet.title,
                initialDraft: sheet.initialDraft,
                onSave: { draft in
                    switch sheet {
                    case .create:
                        return await viewModel.createStory(from: draft)
                    case .edit(let story):
                        return await viewModel.updateStory(story, with: draft)
                    }
                }
            )
        }
        .alert("Error", isPresented: errorBinding, actions: {
            Button("Cerrar") { viewModel.clearError() }
        }, message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        })
        .accessibilityIdentifier("story_management_view")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Cargando historias...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.stories.isEmpty {
            ContentUnavailableView("No hay historias personalizadas", systemImage: "book", description: Text("Crea una historia para empezar."))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.stories) { story in
                    Button {
                        activeSheet = .edit(story)
                    } label: {
                        StoryRowView(story: story)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { offsets in
                    Task { await viewModel.deleteStories(at: offsets) }
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Nueva historia") {
                activeSheet = .create
            }
        }
    }

    private enum ActiveSheet: Identifiable {
        case create
        case edit(CustomStory)

        var id: String {
            switch self {
            case .create:
                return "create"
            case .edit(let story):
                return story.id.uuidString
            }
        }

        var title: String {
            switch self {
            case .create:
                return "Nueva historia"
            case .edit:
                return "Editar historia"
            }
        }

        var initialDraft: StoryDraft {
            switch self {
            case .create:
                return StoryDraft()
            case .edit(let story):
                return StoryDraft(title: story.title, text: story.text, minAge: story.minAge, maxAge: story.maxAge)
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue { viewModel.clearError() }
            }
        )
    }
}

private struct StoryRowView: View {
    let story: CustomStory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.title)
                .font(.headline)
            Text(story.text)
                .lineLimit(2)
                .foregroundStyle(.secondary)
            Text("Edades: \(story.minAge)-\(story.maxAge)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("story_row_\(story.id.uuidString)")
    }
}
