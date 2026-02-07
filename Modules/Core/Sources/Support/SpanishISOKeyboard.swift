import Foundation

public struct SpanishISOKeyboard {
    public static let allowedCharacters: CharacterSet = {
        var set = CharacterSet.letters
        set.insert(charactersIn: "ñÑáéíóúÁÉÍÓÚüÜ")
        set.insert(charactersIn: " ,.;:¡!¿?'-\n")
        return set
    }()

    public static func sanitizeInput(_ text: String) -> String {
        let filtered = text.unicodeScalars.filter { allowedCharacters.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
}
