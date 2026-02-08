import XCTest
import SwiftData
@testable import StoryPersistence
@testable import Stories

final class StoryPersistenceTests: XCTestCase {
    func testSaveAndLoadCustomStory() async throws {
        let container = try makeContainer()
        let repository = SwiftDataCustomStoryRepository(container: container)

        let story = CustomStory(title: "Historia", text: "Este es un texto suficientemente largo para la prueba.", minAge: 7, maxAge: 10)
        try await repository.saveStory(story)

        let loaded = try await repository.loadStories()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, story.title)
    }

    func testDeleteCustomStory() async throws {
        let container = try makeContainer()
        let repository = SwiftDataCustomStoryRepository(container: container)

        let story = CustomStory(title: "Historia", text: "Texto de prueba para eliminar.", minAge: 7, maxAge: 10)
        try await repository.saveStory(story)
        try await repository.deleteStory(id: story.id)

        let loaded = try await repository.loadStories()
        XCTAssertTrue(loaded.isEmpty)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([StoryRecord.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
