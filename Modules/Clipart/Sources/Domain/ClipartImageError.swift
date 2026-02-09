import Foundation

public enum ClipartImageError: LocalizedError, Sendable {
    case invalidResponse
    case decodeFailed
    case svgRenderFailed

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "No se pudo descargar la imagen."
        case .decodeFailed:
            return "No se pudo decodificar la imagen."
        case .svgRenderFailed:
            return "No se pudo renderizar la imagen SVG."
        }
    }
}
