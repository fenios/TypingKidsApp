import Foundation
import Observation

@MainActor
@Observable
public final class CreateUserViewModel {
    public var displayName: String = ""
    public var role: UserRole = .alumno
    public var pin: String = ""
    public private(set) var errorMessage: String? = nil
    public private(set) var isSaving: Bool = false

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

    public func createUser() async -> User? {
        errorMessage = nil
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Escribe un nombre."
            return nil
        }
        guard isValidPin(pin) else {
            errorMessage = "PIN inválido. Debe tener 4 dígitos."
            return nil
        }

        isSaving = true
        let user = User(displayName: trimmed, role: role, pinHash: pinHasher.hash(pin))
        await userRepository.saveUser(user)
        await sessionRepository.setCurrentUserId(user.id)
        isSaving = false
        return user
    }

    private func isValidPin(_ value: String) -> Bool {
        let digits = CharacterSet.decimalDigits
        return value.count == 4 && value.unicodeScalars.allSatisfy { digits.contains($0) }
    }
}
