import Foundation
import CryptoKit

struct LocalAccount: Codable, Identifiable {
    var profile: UserProfile
    var passwordHash: String
    var salt: String

    var id: UUID { profile.id }
}

enum PasswordHasher {
    static func makeSalt(byteCount: Int = 16) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes).base64EncodedString()
    }

    static func hash(password: String, salt: String) -> String {
        let combined = Data((salt + ":" + password).utf8)
        let digest = SHA256.hash(data: combined)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func verify(password: String, salt: String, expectedHash: String) -> Bool {
        hash(password: password, salt: salt) == expectedHash
    }
}
