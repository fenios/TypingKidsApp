import Foundation
import CryptoKit

public actor DiskImageStore {
    private let baseURL: URL
    private let fileManager: FileManager

    public init(baseURL: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let baseURL {
            self.baseURL = baseURL
        } else {
            let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            self.baseURL = (cacheDir ?? fileManager.temporaryDirectory).appendingPathComponent("ClipartCache", isDirectory: true)
        }
        do {
            try fileManager.createDirectory(at: self.baseURL, withIntermediateDirectories: true)
        } catch {
            // Best-effort directory creation.
        }
    }

    public func readData(for url: URL) -> Data? {
        let fileURL = fileURL(for: url)
        return try? Data(contentsOf: fileURL)
    }

    public func write(_ data: Data, for url: URL) {
        let fileURL = fileURL(for: url)
        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Disk caching is best-effort; ignore failures.
        }
    }

    private func fileURL(for url: URL) -> URL {
        let key = url.absoluteString
        let hash = SHA256.hash(data: Data(key.utf8))
        let filename = hash.compactMap { String(format: "%02x", $0) }.joined()
        return baseURL.appendingPathComponent(filename)
    }
}
