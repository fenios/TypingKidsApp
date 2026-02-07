import Foundation
import Observation

@MainActor
@Observable
public final class AccessibilitySettingsViewModel {
    public var settings: AccessibilitySettings
    private let repository: AccessibilitySettingsRepository

    public init(repository: AccessibilitySettingsRepository) {
        self.repository = repository
        self.settings = (try? repository.load()) ?? AccessibilitySettings()
    }

    public func save() {
        try? repository.save(settings)
    }
}
