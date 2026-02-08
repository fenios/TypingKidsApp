import Foundation
import Persistence

public protocol UserSessionRepository: Sendable {
    func currentUserId() async -> UUID?
    func setCurrentUserId(_ id: UUID?) async
}

public actor DefaultUserSessionRepository: UserSessionRepository {
    private let store: KeyValueStore
    private let sessionKey = "current_user_id"

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func currentUserId() async -> UUID? {
        try? store.get(UUID.self, forKey: sessionKey)
    }

    public func setCurrentUserId(_ id: UUID?) async {
        try? store.set(id, forKey: sessionKey)
    }
}
