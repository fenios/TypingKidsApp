import Foundation
import Observation

@MainActor
@Observable
public final class LoginViewModel {
    public private(set) var users: [User] = []
    public var selectedUser: User? = nil
    public var pin: String = ""
    public private(set) var errorMessage: String? = nil
    public private(set) var isLoading: Bool = false

    private let userRepository: UserRepository
    private let sessionRepository: UserSessionRepository
    private let pinHasher: PinHasher

    public init(
        userRepository: UserRepository,
        sessionRepository: UserSessionRepository,
        pinHasher: PinHasher = PinHasher()
    ) {
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
        self.pinHasher = pinHasher
    }

    public func loadUsers() async {
        isLoading = true
        let loaded = await userRepository.loadUsers()
        users = loaded.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
        if selectedUser == nil {
            selectedUser = users.first
        }
        isLoading = false
    }

    public func login() async -> User? {
        errorMessage = nil
        guard let user = selectedUser else {
            errorMessage = "Selecciona un usuario."
            return nil
        }
        guard isValidPin(pin) else {
            errorMessage = "PIN inválido. Debe tener 4 dígitos."
            return nil
        }
        let hashed = pinHasher.hash(pin)
        guard hashed == user.pinHash else {
            errorMessage = "PIN incorrecto."
            return nil
        }
        await sessionRepository.setCurrentUserId(user.id)
        return user
    }

    private func isValidPin(_ value: String) -> Bool {
        let digits = CharacterSet.decimalDigits
        return value.count == 4 && value.unicodeScalars.allSatisfy { digits.contains($0) }
    }
}
