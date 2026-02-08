import Foundation
import Core

public enum TypingSessionState: Equatable {
    case idle
    case inProgress
    case finished(TypingResult)
}
