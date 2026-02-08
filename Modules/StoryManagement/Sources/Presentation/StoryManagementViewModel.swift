import Foundation
import Observation
import Stories

@MainActor
@Observable
public final class StoryManagementViewModel {
    public private(set) var stories: [CustomStory] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String? = nil

    private let repository: CustomStoryRepository
    private let createdByUserId: UUID?

    public init(repository: CustomStoryRepository, createdByUserId: UUID?) {
        self.repository = repository
        self.createdByUserId = createdByUserId
    }

    public func loadStories() async {
        isLoading = true
        do {
            let loaded = try await repository.loadStories()
            stories = loaded.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron cargar las historias."
        }
        isLoading = false
    }

    public func clearError() {
        errorMessage = nil
    }

    public func createStory(from draft: StoryDraft) async -> StoryFormError? {
        if let error = validate(draft) {
            return error
        }
        let story = CustomStory(
            title: draft.title,
            text: draft.text,
            minAge: draft.minAge,
            maxAge: draft.maxAge,
            createdAt: Date(),
            createdByUserId: createdByUserId
        )
        do {
            try await repository.saveStory(story)
            await loadStories()
            return nil
        } catch {
            return .persistenceFailed
        }
    }

    public func updateStory(_ story: CustomStory, with draft: StoryDraft) async -> StoryFormError? {
        if let error = validate(draft) {
            return error
        }
        let updated = CustomStory(
            id: story.id,
            title: draft.title,
            text: draft.text,
            minAge: draft.minAge,
            maxAge: draft.maxAge,
            createdAt: story.createdAt,
            createdByUserId: story.createdByUserId
        )
        do {
            try await repository.saveStory(updated)
            await loadStories()
            return nil
        } catch {
            return .persistenceFailed
        }
    }

    public func deleteStories(at offsets: IndexSet) async {
        let ids = offsets.map { stories[$0].id }
        await deleteStories(ids: ids)
    }

    public func deleteStories(ids: [UUID]) async {
        for id in ids {
            try? await repository.deleteStory(id: id)
        }
        await loadStories()
    }

    public func draft(from story: CustomStory) -> StoryDraft {
        StoryDraft(
            title: story.title,
            text: story.text,
            minAge: story.minAge,
            maxAge: story.maxAge
        )
    }

    private func validate(_ draft: StoryDraft) -> StoryFormError? {
        let trimmedTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedText = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.count < 3 {
            return .titleTooShort
        }
        if trimmedText.count < 20 {
            return .textTooShort
        }
        if draft.minAge > draft.maxAge {
            return .invalidAgeRange
        }
        return nil
    }
}
