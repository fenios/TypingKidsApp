import XCTest
@testable import LanguageProcessing

final class TextNormalizerTests: XCTestCase {
    func testNormalizeRemovesDiacriticsExceptEnye() {
        let normalizer = TextNormalizer()
        let input = "¡Niño, pingüino y canción!"
        let normalized = normalizer.normalize(input)
        XCTAssertEqual(normalized, "niño pinguino y cancion")
    }
}
