import Foundation

public struct TypingMetrics: Equatable, Codable {
    public let reactionTime: TimeInterval
    public let totalTime: TimeInterval
    public let errorCount: Int

    public init(reactionTime: TimeInterval, totalTime: TimeInterval, errorCount: Int) {
        self.reactionTime = reactionTime
        self.totalTime = totalTime
        self.errorCount = errorCount
    }
}

public struct WordTiming: Equatable, Codable {
    public let word: String
    public let duration: TimeInterval

    public init(word: String, duration: TimeInterval) {
        self.word = word
        self.duration = duration
    }
}

public struct ReadingMetrics: Equatable, Codable {
    public let wordTimings: [WordTiming]
    public let totalTime: TimeInterval

    public init(wordTimings: [WordTiming], totalTime: TimeInterval) {
        self.wordTimings = wordTimings
        self.totalTime = totalTime
    }

    public var averageWordTime: TimeInterval {
        guard !wordTimings.isEmpty else { return 0 }
        let total = wordTimings.reduce(0) { $0 + $1.duration }
        return total / Double(wordTimings.count)
    }
}
