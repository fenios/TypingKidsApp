import Foundation
import Core

public struct ReadingResult: Codable, Equatable, Identifiable {
    public let id: UUID
    public let storyId: UUID
    public let date: Date
    public let metrics: ReadingMetrics

    public init(id: UUID = UUID(), storyId: UUID, date: Date, metrics: ReadingMetrics) {
        self.id = id
        self.storyId = storyId
        self.date = date
        self.metrics = metrics
    }
}

public enum ReadingSessionState: Equatable {
    case idle
    case inProgress
    case finished(ReadingResult)
}
