import Foundation

public struct StoryDraft: Equatable, Sendable {
    public var title: String
    public var text: String
    public var minAge: Int
    public var maxAge: Int

    public init(title: String = "", text: String = "", minAge: Int = 7, maxAge: Int = 10) {
        self.title = title
        self.text = text
        self.minAge = minAge
        self.maxAge = maxAge
    }
}

public enum StoryFormError: Error, LocalizedError, Equatable {
    case titleTooShort
    case textTooShort
    case invalidAgeRange
    case persistenceFailed

    public var errorDescription: String? {
        switch self {
        case .titleTooShort:
            return "El título debe tener al menos 3 caracteres."
        case .textTooShort:
            return "El texto debe tener al menos 20 caracteres."
        case .invalidAgeRange:
            return "La edad mínima debe ser menor o igual a la máxima."
        case .persistenceFailed:
            return "No se pudo guardar la historia."
        }
    }
}
