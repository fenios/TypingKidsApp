import XCTest
@testable import Stories

final class StoryRepositoryTests: XCTestCase {
    func testLoadsStoriesFromBundle() throws {
        let bundle = Bundle(for: StoryRepositoryTests.self)
        let repository = LocalStoryRepository(bundle: bundle)
        let stories = try repository.loadStories()
        XCTAssertEqual(stories.count, 1)
        XCTAssertEqual(stories.first?.title, "Prueba")
    }
}
