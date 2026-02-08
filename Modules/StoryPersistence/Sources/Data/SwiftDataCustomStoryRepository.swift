import Foundation
import SwiftData
import Stories

public actor SwiftDataCustomStoryRepository: CustomStoryRepository {
    private let container: ModelContainer
    private let context: ModelContext

    public init(container: ModelContainer) {
        self.container = container
        self.context = ModelContext(container)
    }

    public func loadStories() async throws -> [CustomStory] {
        let descriptor = FetchDescriptor<StoryRecord>(sortBy: [SortDescriptor(\.createdAt)])
        let records = try context.fetch(descriptor)
        return records.map { $0.toCustomStory() }
    }

    public func saveStory(_ story: CustomStory) async throws {
        if let existing = try fetchRecord(id: story.id) {
            existing.update(from: story)
        } else {
            context.insert(StoryRecord(story: story))
        }
        try context.save()
    }

    public func deleteStory(id: UUID) async throws {
        guard let existing = try fetchRecord(id: id) else {
            throw CustomStoryRepositoryError.notFound
        }
        context.delete(existing)
        try context.save()
    }

    private func fetchRecord(id: UUID) throws -> StoryRecord? {
        let predicate = #Predicate<StoryRecord> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor).first
    }
}
