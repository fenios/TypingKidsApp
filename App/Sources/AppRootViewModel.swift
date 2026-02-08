import Foundation
import Observation
import UserManagement

@MainActor
@Observable
final class AppRootViewModel {
    private let sessionRepository: UserSessionRepository
    private let userRepository: UserRepository

    public private(set) var currentUser: User? = nil
    public private(set) var isLoading: Bool = true

    init(dependencies: AppDependencies) {
        self.sessionRepository = dependencies.sessionRepository
        self.userRepository = dependencies.userRepository
    }

    func loadSession() async {
        isLoading = true
        if let id = await sessionRepository.currentUserId() {
            currentUser = await userRepository.user(id: id)
        } else {
            currentUser = nil
        }
        isLoading = false
    }

    func handleLogin(_ user: User) {
        currentUser = user
    }

    func logout() async {
        await sessionRepository.setCurrentUserId(nil)
        currentUser = nil
    }
}
