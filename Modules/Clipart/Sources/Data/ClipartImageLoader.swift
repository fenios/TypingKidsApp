import Foundation
import AppKit

@MainActor
public protocol ClipartImageLoading: Sendable {
    func loadImage(from url: URL) async throws -> NSImage
}

@MainActor
public final class ClipartImageLoader: ClipartImageLoading {
    private let networkClient: NetworkClient
    private let cache: ClipartImageCaching
    private let decoder: ClipartImageDecoding

    public init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        cache: ClipartImageCaching = DefaultClipartImageCache(),
        decoder: ClipartImageDecoding = DefaultClipartImageDecoder()
    ) {
        self.networkClient = networkClient
        self.cache = cache
        self.decoder = decoder
    }

    public func loadImage(from url: URL) async throws -> NSImage {
        if let cachedData = await cache.data(for: url) {
            let format = ClipartImageFormat.detect(url: url, mimeType: nil)
            return try await decoder.decode(cachedData, format: format)
        }

        let response = try await networkClient.fetch(url)
        let format = ClipartImageFormat.detect(url: url, mimeType: response.mimeType)
        await cache.store(response.data, for: url)
        return try await decoder.decode(response.data, format: format)
    }
}

@MainActor
public final class ClipartImageLoaderMock: ClipartImageLoading {
    private let image: NSImage

    public init(image: NSImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil) ?? NSImage()) {
        self.image = image
    }

    public func loadImage(from url: URL) async throws -> NSImage {
        image
    }
}
