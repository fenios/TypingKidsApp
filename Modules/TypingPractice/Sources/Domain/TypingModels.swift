import Foundation
import Core

public struct TypingResult: Codable, Equatable, Identifiable {
    public let id: UUID
    public let storyId: UUID
    public let date: Date
    public let metrics: TypingMetrics

    public init(id: UUID = UUID(), storyId: UUID, date: Date, metrics: TypingMetrics) {
        self.id = id
        self.storyId = storyId
        self.date = date
        self.metrics = metrics
    }
}

public enum TypingSessionState: Equatable {
    case idle
    case inProgress
    case finished(TypingResult)
}
