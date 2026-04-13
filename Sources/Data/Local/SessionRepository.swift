import Foundation

// MARK: - Session Storage (iOS Equivalent to DataStore)

final class SessionRepository: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let keyUserId = "dailymath.session.userId"
    private let keyIsModerator = "dailymath.session.isModerator"
    private let keyIsLoggedIn = "dailymath.session.isLoggedIn"

    @Published var isLoggedIn: Bool = false
    @Published var userId: String?
    @Published var isModerator: Bool = false

    static let shared = SessionRepository()

    private init() {
        self.isLoggedIn = userDefaults.bool(forKey: keyIsLoggedIn)
        self.userId = userDefaults.string(forKey: keyUserId)
        self.isModerator = userDefaults.bool(forKey: keyIsModerator)
    }

    func saveSession(userId: String, isModerator: Bool) {
        userDefaults.set(true, forKey: keyIsLoggedIn)
        userDefaults.set(userId, forKey: keyUserId)
        userDefaults.set(isModerator, forKey: keyIsModerator)
        
        self.isLoggedIn = true
        self.userId = userId
        self.isModerator = isModerator
    }

    func clearSession() {
        userDefaults.set(false, forKey: keyIsLoggedIn)
        userDefaults.removeObject(forKey: keyUserId)
        userDefaults.removeObject(forKey: keyIsModerator)
        
        self.isLoggedIn = false
        self.userId = nil
        self.isModerator = false
    }
}
