import Foundation
import AppKit

@MainActor
public protocol ClipartImageDecoding: Sendable {
    func decode(_ data: Data, format: ClipartImageFormat) async throws -> NSImage
}

@MainActor
public protocol SVGRendering: Sendable {
    func render(svgData: Data, targetSize: CGSize) async throws -> NSImage
}

@MainActor
public struct DefaultClipartImageDecoder: ClipartImageDecoding {
    private let svgRenderer: SVGRendering
    private let targetSize: CGSize

    public init(svgRenderer: SVGRendering = SVGRenderer(), targetSize: CGSize = CGSize(width: 512, height: 512)) {
        self.svgRenderer = svgRenderer
        self.targetSize = targetSize
    }

    public func decode(_ data: Data, format: ClipartImageFormat) async throws -> NSImage {
        switch format {
        case .svg:
            return try await svgRenderer.render(svgData: data, targetSize: targetSize)
        default:
            if let image = NSImage(data: data) {
                return image
            }
            throw ClipartImageError.decodeFailed
        }
    }
}
