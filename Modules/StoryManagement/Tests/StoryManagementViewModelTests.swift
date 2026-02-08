import XCTest
@testable import StoryManagement
@testable import Stories

final class StoryManagementViewModelTests: XCTestCase {
    func testValidationRejectsShortTitle() async {
        let repository = RecordingCustomStoryRepository()
        let viewModel = StoryManagementViewModel(repository: repository, createdByUserId: UUID())

        let draft = StoryDraft(title: "Hi", text: String(repeating: "a", count: 30), minAge: 7, maxAge: 10)
        let error = await viewModel.createStory(from: draft)

        XCTAssertEqual(error, .titleTooShort)
        let saved = await repository.savedStories
        XCTAssertTrue(saved.isEmpty)
    }

    func testCreateStoryPersists() async {
        let repository = RecordingCustomStoryRepository()
        let viewModel = StoryManagementViewModel(repository: repository, createdByUserId: UUID())

        let draft = StoryDraft(title: "Historia", text: String(repeating: "a", count: 30), minAge: 7, maxAge: 10)
        let error = await viewModel.createStory(from: draft)

        XCTAssertNil(error)
        let saved = await repository.savedStories
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.title, "Historia")
    }
}

private actor RecordingCustomStoryRepository: CustomStoryRepository {
    private(set) var savedStories: [CustomStory] = []

    func loadStories() async throws -> [CustomStory] {
        savedStories
    }

    func saveStory(_ story: CustomStory) async throws {
        if let index = savedStories.firstIndex(where: { $0.id == story.id }) {
            savedStories[index] = story
        } else {
            savedStories.append(story)
        }
    }

    func deleteStory(id: UUID) async throws {
        savedStories.removeAll { $0.id == id }
    }
}
