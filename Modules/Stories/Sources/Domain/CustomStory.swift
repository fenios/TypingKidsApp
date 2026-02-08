import Foundation

public struct CustomStory: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var text: String
    public var minAge: Int
    public var maxAge: Int
    public let createdAt: Date
    public var createdByUserId: UUID?

    public init(
        id: UUID = UUID(),
        title: String,
        text: String,
        minAge: Int,
        maxAge: Int,
        createdAt: Date = Date(),
        createdByUserId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.minAge = minAge
        self.maxAge = maxAge
        self.createdAt = createdAt
        self.createdByUserId = createdByUserId
    }
}

public extension Story {
    init(customStory: CustomStory) {
        self.init(
            id: customStory.id,
            title: customStory.title,
            text: customStory.text,
            minAge: customStory.minAge,
            maxAge: customStory.maxAge
        )
    }
}
