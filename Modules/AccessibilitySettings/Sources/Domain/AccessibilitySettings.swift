import Foundation
import Persistence

public struct AccessibilitySettings: Codable, Equatable {
    public var fontScale: Double
    public var highContrast: Bool

    public init(fontScale: Double = 1.0, highContrast: Bool = false) {
        self.fontScale = fontScale
        self.highContrast = highContrast
    }
}

public protocol AccessibilitySettingsRepository {
    func load() throws -> AccessibilitySettings
    func save(_ settings: AccessibilitySettings) throws
}

public struct DefaultAccessibilitySettingsRepository: AccessibilitySettingsRepository {
    private let store: KeyValueStore
    private let key = "accessibility_settings"

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func load() throws -> AccessibilitySettings {
        if let value = try store.get(AccessibilitySettings.self, forKey: key) {
            return value
        }
        return AccessibilitySettings()
    }

    public func save(_ settings: AccessibilitySettings) throws {
        try store.set(settings, forKey: key)
    }
}
