import XCTest
@testable import TypingKidsApp

final class AppDependenciesTests: XCTestCase {
    func testDependenciesBuild() {
        let dependencies = AppDependencies()
        XCTAssertNotNil(dependencies)
    }
}
