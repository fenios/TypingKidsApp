import Foundation

public struct TypingResult: Codable, Equatable, Identifiable, Sendable {
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

public struct ReadingResult: Codable, Equatable, Identifiable, Sendable {
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
