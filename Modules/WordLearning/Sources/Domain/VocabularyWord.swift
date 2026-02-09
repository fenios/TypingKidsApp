import Foundation

public struct VocabularyWord: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let word: String
    public let imageURL: URL
    public let source: String

    public init(id: UUID = UUID(), word: String, imageURL: URL, source: String) {
        self.id = id
        self.word = word
        self.imageURL = imageURL
        self.source = source
    }
}
