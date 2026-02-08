import Foundation

public enum UserRole: String, Codable, CaseIterable, Sendable, Identifiable {
    case tutor
    case alumno

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .tutor: return "Tutor"
        case .alumno: return "Alumno"
        }
    }
}

public struct User: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var displayName: String
    public var role: UserRole
    public var pinHash: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        displayName: String,
        role: UserRole,
        pinHash: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.role = role
        self.pinHash = pinHash
        self.createdAt = createdAt
    }
}
