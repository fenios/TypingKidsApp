import Foundation
import Persistence

public protocol UserRepository: Sendable {
    func loadUsers() async -> [User]
    func saveUser(_ user: User) async
    func user(id: UUID) async -> User?
}

public actor DefaultUserRepository: UserRepository {
    private let store: KeyValueStore
    private let usersKey = "users"

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func loadUsers() async -> [User] {
        (try? store.get([User].self, forKey: usersKey)) ?? []
    }

    public func saveUser(_ user: User) async {
        var users = (try? store.get([User].self, forKey: usersKey)) ?? []
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        try? store.set(users, forKey: usersKey)
    }

    public func user(id: UUID) async -> User? {
        let users = (try? store.get([User].self, forKey: usersKey)) ?? []
        return users.first { $0.id == id }
    }
}
