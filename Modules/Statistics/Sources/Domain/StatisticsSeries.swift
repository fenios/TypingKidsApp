import Foundation

public struct ChartPoint: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let date: Date
    public let value: Double

    public init(id: UUID = UUID(), date: Date, value: Double) {
        self.id = id
        self.date = date
        self.value = value
    }
}

public struct StatisticsSeries: Sendable, Equatable {
    public let wpmPoints: [ChartPoint]
    public let averageWordTimePoints: [ChartPoint]
    public let typingErrorPoints: [ChartPoint]

    public init(
        wpmPoints: [ChartPoint],
        averageWordTimePoints: [ChartPoint],
        typingErrorPoints: [ChartPoint]
    ) {
        self.wpmPoints = wpmPoints
        self.averageWordTimePoints = averageWordTimePoints
        self.typingErrorPoints = typingErrorPoints
    }

    public static var empty: StatisticsSeries {
        StatisticsSeries(wpmPoints: [], averageWordTimePoints: [], typingErrorPoints: [])
    }

    public var isEmpty: Bool {
        wpmPoints.isEmpty && averageWordTimePoints.isEmpty && typingErrorPoints.isEmpty
    }
}
