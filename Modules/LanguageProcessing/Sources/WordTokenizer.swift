import Foundation

public struct WordTokenizer: Sendable {
    public init() {}

    public func tokenize(_ text: String) -> [String] {
        text.split(whereSeparator: { !$0.isLetter }).map(String.init)
    }
}
