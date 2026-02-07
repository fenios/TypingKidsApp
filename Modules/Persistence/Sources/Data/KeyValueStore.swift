import Foundation

public protocol KeyValueStore {
    func set<T: Codable>(_ value: T, forKey key: String) throws
    func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
}

public enum KeyValueStoreError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case writeFailed
    case readFailed

    public var errorDescription: String? {
        switch self {
        case .encodingFailed: return "Failed to encode value."
        case .decodingFailed: return "Failed to decode value."
        case .writeFailed: return "Failed to write value."
        case .readFailed: return "Failed to read value."
        }
    }
}
