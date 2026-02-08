import Foundation

public struct TextNormalizer: Sendable {
    public init() {}

    public func normalize(_ text: String) -> String {
        let placeholder = "__enye__"
        var working = text
            .replacingOccurrences(of: "ñ", with: placeholder)
            .replacingOccurrences(of: "Ñ", with: placeholder)

        working = working.folding(options: [.diacriticInsensitive], locale: Locale(identifier: "es_ES"))
        working = working.lowercased(with: Locale(identifier: "es_ES"))
        working = working.replacingOccurrences(of: placeholder, with: "ñ")

        let allowed = CharacterSet.letters.union(.whitespacesAndNewlines)
        let filteredScalars = working.unicodeScalars.filter { allowed.contains($0) }
        var filtered = String(String.UnicodeScalarView(filteredScalars))
        filtered = filtered
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return filtered
    }
}
