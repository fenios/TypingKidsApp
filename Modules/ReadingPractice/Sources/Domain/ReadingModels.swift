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

public enum ReadingAlgorithm: Equatable, Codable, Sendable {
    case sequentialStorySpeech
    case syllableFilteredSpeech(syllableCount: Int)
}

public enum ReadingAlgorithmOption: String, CaseIterable, Identifiable, Sendable {
    case sequentialStorySpeech
    case syllableFilteredSpeech

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .sequentialStorySpeech:
            return "Lectura del texto"
        case .syllableFilteredSpeech:
            return "Por sílabas"
        }
    }

    public func algorithm(syllableCount: Int) -> ReadingAlgorithm {
        switch self {
        case .sequentialStorySpeech:
            return .sequentialStorySpeech
        case .syllableFilteredSpeech:
            return .syllableFilteredSpeech(syllableCount: syllableCount)
        }
    }
}

public enum ReadingSessionState: Equatable {
    case idle
    case inProgress
    case finished(ReadingResult)
}
