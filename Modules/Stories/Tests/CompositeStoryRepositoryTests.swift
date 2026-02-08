import XCTest
@testable import Stories

final class CompositeStoryRepositoryTests: XCTestCase {
    func testCompositeRepositoryMergesAndSortsStories() async throws {
        let localStory = Story(id: UUID(), title: "Beta", text: "Texto local", minAge: 7, maxAge: 10)
        let customStory = CustomStory(title: "Alpha", text: "Texto custom", minAge: 7, maxAge: 10)

        let localRepository = StaticStoryRepository(stories: [localStory])
        let customRepository = InMemoryCustomStoryRepository(stories: [customStory])

        let composite = CompositeStoryRepository(localRepository: localRepository, customRepository: customRepository)
        let result = try await composite.loadStories()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.title, "Alpha")
        XCTAssertEqual(result.last?.title, "Beta")
    }
}

private actor StaticStoryRepository: StoryRepository {
    private let stories: [Story]

    init(stories: [Story]) {
        self.stories = stories
    }

    func loadStories() async throws -> [Story] {
        stories
    }
}

private actor InMemoryCustomStoryRepository: CustomStoryRepository {
    private var stories: [CustomStory]

    init(stories: [CustomStory]) {
        self.stories = stories
    }

    func loadStories() async throws -> [CustomStory] {
        stories
    }

    func saveStory(_ story: CustomStory) async throws {
        stories.append(story)
    }

    func deleteStory(id: UUID) async throws {
        stories.removeAll { $0.id == id }
    }
}
