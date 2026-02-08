import Foundation
import Core

public protocol StatisticsCalculating: Sendable {
    func makeSeries(reading: [ReadingResult], typing: [TypingResult]) -> StatisticsSeries
}

public struct StatisticsCalculator: StatisticsCalculating {
    public init() {}

    public func makeSeries(reading: [ReadingResult], typing: [TypingResult]) -> StatisticsSeries {
        let readingSorted = reading.sorted { $0.date < $1.date }
        let typingSorted = typing.sorted { $0.date < $1.date }

        let wpmPoints = readingSorted.map { result in
            let wordCount = result.metrics.wordTimings.count
            let totalTime = result.metrics.totalTime
            let wpm = totalTime > 0 ? (Double(wordCount) / totalTime) * 60 : 0
            return ChartPoint(date: result.date, value: wpm)
        }

        let avgWordPoints = readingSorted.map { result in
            ChartPoint(date: result.date, value: result.metrics.averageWordTime)
        }

        let typingErrorPoints = typingSorted.map { result in
            ChartPoint(date: result.date, value: Double(result.metrics.errorCount))
        }

        return StatisticsSeries(
            wpmPoints: wpmPoints,
            averageWordTimePoints: avgWordPoints,
            typingErrorPoints: typingErrorPoints
        )
    }
}
