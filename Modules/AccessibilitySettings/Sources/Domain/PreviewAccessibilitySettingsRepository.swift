import Foundation

public struct PreviewAccessibilitySettingsRepository: AccessibilitySettingsRepository {
    public init() {}

    public func load() throws -> AccessibilitySettings {
        AccessibilitySettings()
    }

    public func save(_ settings: AccessibilitySettings) throws {}
}
