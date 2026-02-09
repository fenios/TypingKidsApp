import XCTest
import AppKit
@testable import Clipart

@MainActor
final class ClipartImageLoaderTests: XCTestCase {
    func testUsesCacheBeforeNetwork() async throws {
        let url = URL(string: "https://example.com/image.png")!
        let cachedData = Data([0x01, 0x02, 0x03])
        let cache = InMemoryCache(seed: [url: cachedData])
        let network = MockNetworkClient()
        let decoder = StubDecoder()
        let loader = ClipartImageLoader(networkClient: network, cache: cache, decoder: decoder)

        _ = try await loader.loadImage(from: url)

        let fetchCount = await network.fetchCount
        XCTAssertEqual(fetchCount, 0)
        XCTAssertEqual(decoder.lastData, cachedData)
    }

    func testStoresNetworkDataInCache() async throws {
        let url = URL(string: "https://example.com/image.png")!
        let data = Data([0x10, 0x11, 0x12])
        let cache = InMemoryCache()
        let network = MockNetworkClient(response: NetworkResponse(data: data, mimeType: "image/png"))
        let decoder = StubDecoder()
        let loader = ClipartImageLoader(networkClient: network, cache: cache, decoder: decoder)

        _ = try await loader.loadImage(from: url)

        let stored = await cache.data(for: url)
        XCTAssertEqual(stored, data)
    }
}

private actor InMemoryCache: ClipartImageCaching {
    private var storage: [URL: Data]

    init(seed: [URL: Data] = [:]) {
        self.storage = seed
    }

    func data(for url: URL) async -> Data? {
        storage[url]
    }

    func store(_ data: Data, for url: URL) async {
        storage[url] = data
    }
}

private actor MockNetworkClient: NetworkClient {
    let response: NetworkResponse
    private(set) var fetchCount: Int = 0

    init(response: NetworkResponse = NetworkResponse(data: Data([0x01]), mimeType: "image/png")) {
        self.response = response
    }

    func fetch(_ url: URL) async throws -> NetworkResponse {
        fetchCount += 1
        return response
    }
}

@MainActor
private final class StubDecoder: ClipartImageDecoding {
    private(set) var lastData: Data? = nil

    func decode(_ data: Data, format: ClipartImageFormat) async throws -> NSImage {
        lastData = data
        return NSImage(size: NSSize(width: 10, height: 10))
    }
}
