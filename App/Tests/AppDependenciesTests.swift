import XCTest
@testable import TypingKidsApp

@MainActor
final class AppDependenciesTests: XCTestCase {
    func testDependenciesBuild() {
        let dependencies = AppDependencies()
        XCTAssertNotNil(dependencies)
    }
}
