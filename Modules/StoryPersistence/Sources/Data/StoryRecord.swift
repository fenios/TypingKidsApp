import Foundation
import SwiftData
import Stories

@Model
public final class StoryRecord {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var text: String
    public var minAge: Int
    public var maxAge: Int
    public var createdAt: Date
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

public extension StoryRecord {
    convenience init(story: CustomStory) {
        self.init(
            id: story.id,
            title: story.title,
            text: story.text,
            minAge: story.minAge,
            maxAge: story.maxAge,
            createdAt: story.createdAt,
            createdByUserId: story.createdByUserId
        )
    }

    func update(from story: CustomStory) {
        title = story.title
        text = story.text
        minAge = story.minAge
        maxAge = story.maxAge
        createdAt = story.createdAt
        createdByUserId = story.createdByUserId
    }

    func toCustomStory() -> CustomStory {
        CustomStory(
            id: id,
            title: title,
            text: text,
            minAge: minAge,
            maxAge: maxAge,
            createdAt: createdAt,
            createdByUserId: createdByUserId
        )
    }
}
