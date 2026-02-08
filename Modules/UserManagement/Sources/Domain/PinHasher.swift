import Foundation
import CryptoKit

public struct PinHasher: Sendable {
    public init() {}

    public func hash(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
