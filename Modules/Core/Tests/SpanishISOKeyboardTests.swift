import XCTest
@testable import Core

final class SpanishISOKeyboardTests: XCTestCase {
    func testSanitizeInputRemovesUnsupportedCharacters() {
        let input = "Hola! 123 ñandú"
        let result = SpanishISOKeyboard.sanitizeInput(input)
        XCTAssertEqual(result, "Hola!  ñandú")
    }
}
