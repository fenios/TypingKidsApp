import XCTest
@testable import Statistics
import Core

final class StatisticsCalculatorTests: XCTestCase {
    func testCalculatorBuildsSeries() {
        let now = Date(timeIntervalSince1970: 0)
        let wordTimings = [
            WordTiming(word: "hola", duration: 1),
            WordTiming(word: "mundo", duration: 1)
        ]
        let readingMetrics = ReadingMetrics(wordTimings: wordTimings, totalTime: 2)
        let reading = [ReadingResult(storyId: UUID(), date: now, metrics: readingMetrics)]

        let typingMetrics = TypingMetrics(reactionTime: 0.5, totalTime: 3, errorCount: 2)
        let typing = [TypingResult(storyId: UUID(), date: now, metrics: typingMetrics)]

        let calculator = StatisticsCalculator()
        let series = calculator.makeSeries(reading: reading, typing: typing)

        XCTAssertEqual(series.wpmPoints.count, 1)
        XCTAssertEqual(series.averageWordTimePoints.count, 1)
        XCTAssertEqual(series.typingErrorPoints.count, 1)
        XCTAssertEqual(series.wpmPoints.first?.value, 60, accuracy: 0.01)
        XCTAssertEqual(series.averageWordTimePoints.first?.value, 1, accuracy: 0.01)
        XCTAssertEqual(series.typingErrorPoints.first?.value, 2, accuracy: 0.01)
    }
}
