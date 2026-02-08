import XCTest
@testable import LanguageProcessing

final class WordTokenizerTests: XCTestCase {
    func testTokenizeKeepsAccents() {
        let tokenizer = WordTokenizer()
        let input = "Hola, ¿qué tal? Niño." 
        let tokens = tokenizer.tokenize(input)
        XCTAssertEqual(tokens, ["Hola", "qué", "tal", "Niño"])
    }
}
