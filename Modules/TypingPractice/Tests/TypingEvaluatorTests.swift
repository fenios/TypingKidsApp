import XCTest
@testable import TypingPractice

final class TypingEvaluatorTests: XCTestCase {
    func testErrorCountIncludesMissingAndExtraCharacters() {
        let evaluator = TypingEvaluator()
        let metrics = evaluator.evaluate(
            target: "hola",
            typed: "hol",
            startedAt: Date(timeIntervalSince1970: 0),
            firstKeyAt: Date(timeIntervalSince1970: 1),
            endedAt: Date(timeIntervalSince1970: 4)
        )
        XCTAssertEqual(metrics.errorCount, 1)
    }
}
