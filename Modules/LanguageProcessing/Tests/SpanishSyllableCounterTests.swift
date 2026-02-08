import XCTest
@testable import LanguageProcessing

final class SpanishSyllableCounterTests: XCTestCase {
    func testCountsBasicWords() {
        let counter = SpanishSyllableCounter()
        XCTAssertEqual(counter.countSyllables(in: "casa"), 2)
        XCTAssertEqual(counter.countSyllables(in: "sol"), 1)
    }

    func testCountsWithAccentsAndDiphthongs() {
        let counter = SpanishSyllableCounter()
        XCTAssertEqual(counter.countSyllables(in: "camión"), 2)
        XCTAssertEqual(counter.countSyllables(in: "huevo"), 2)
        XCTAssertEqual(counter.countSyllables(in: "pingüino"), 3)
    }
}
