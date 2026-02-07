import Foundation

public final class FileKeyValueStore: KeyValueStore {
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(appIdentifier: String) throws {
        let baseURL = try FileKeyValueStore.applicationSupportDirectory()
        directoryURL = baseURL.appendingPathComponent(appIdentifier, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    public func set<T: Codable>(_ value: T, forKey key: String) throws {
        guard let data = try? encoder.encode(value) else { throw KeyValueStoreError.encodingFailed }
        let url = fileURL(forKey: key)
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            throw KeyValueStoreError.writeFailed
        }
    }

    public func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        let url = fileURL(forKey: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            guard let value = try? decoder.decode(T.self, from: data) else { throw KeyValueStoreError.decodingFailed }
            return value
        } catch {
            throw KeyValueStoreError.readFailed
        }
    }

    private func fileURL(forKey key: String) -> URL {
        directoryURL.appendingPathComponent("\(key).json")
    }

    private static func applicationSupportDirectory() throws -> URL {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw KeyValueStoreError.readFailed
        }
        return url
    }
}

public final class InMemoryKeyValueStore: KeyValueStore {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    public func set<T: Codable>(_ value: T, forKey key: String) throws {
        guard let data = try? encoder.encode(value) else { throw KeyValueStoreError.encodingFailed }
        storage[key] = data
    }

    public func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = storage[key] else { return nil }
        guard let value = try? decoder.decode(T.self, from: data) else { throw KeyValueStoreError.decodingFailed }
        return value
    }
}
