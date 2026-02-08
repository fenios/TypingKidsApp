import Foundation

public protocol CustomStoryRepository: Sendable {
    func loadStories() async throws -> [CustomStory]
    func saveStory(_ story: CustomStory) async throws
    func deleteStory(id: UUID) async throws
}

public enum CustomStoryRepositoryError: Error, LocalizedError {
    case notFound
    case persistenceFailed

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Story not found."
        case .persistenceFailed:
            return "Failed to persist story."
        }
    }
}
