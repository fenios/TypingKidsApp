import Foundation

public enum ClipartImageFormat: Sendable {
    case png
    case jpeg
    case svg
    case unknown

    public var isVector: Bool {
        self == .svg
    }

    public static func detect(url: URL, mimeType: String?) -> ClipartImageFormat {
        if let mimeType {
            let normalized = mimeType.lowercased()
            if normalized.contains("image/svg") { return .svg }
            if normalized.contains("image/png") { return .png }
            if normalized.contains("image/jpeg") || normalized.contains("image/jpg") { return .jpeg }
        }

        let ext = url.pathExtension.lowercased()
        switch ext {
        case "svg": return .svg
        case "png": return .png
        case "jpg", "jpeg": return .jpeg
        default: return .unknown
        }
    }
}
