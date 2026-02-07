import Foundation

public struct Story: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let text: String
    public let minAge: Int
    public let maxAge: Int

    public init(id: UUID, title: String, text: String, minAge: Int, maxAge: Int) {
        self.id = id
        self.title = title
        self.text = text
        self.minAge = minAge
        self.maxAge = maxAge
    }

    public var words: [String] {
        text
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0) }
    }
}
