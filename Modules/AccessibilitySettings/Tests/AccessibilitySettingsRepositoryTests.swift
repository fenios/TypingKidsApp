import XCTest
@testable import AccessibilitySettings
import Persistence

final class AccessibilitySettingsRepositoryTests: XCTestCase {
    func testLoadDefaultWhenEmpty() throws {
        let store = InMemoryKeyValueStore()
        let repository = DefaultAccessibilitySettingsRepository(store: store)
        let settings = try repository.load()
        XCTAssertEqual(settings, AccessibilitySettings())
    }
}
