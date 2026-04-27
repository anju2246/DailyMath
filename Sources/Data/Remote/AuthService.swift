import SwiftUI
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let accountStore = LocalStore<LocalAccount>(filename: "accounts")
    private let session = SessionRepository.shared

    enum AuthError: LocalizedError {
        case emailAlreadyTaken
        case invalidCredentials
        case userNotFound
        case weakPassword
        case invalidEmail

        var errorDescription: String? {
            switch self {
            case .emailAlreadyTaken: return "Ya existe una cuenta con ese correo."
            case .invalidCredentials: return "Correo o contraseña incorrectos."
            case .userNotFound: return "No encontramos una cuenta con ese correo."
            case .weakPassword: return "La contraseña debe tener al menos 6 caracteres."
            case .invalidEmail: return "El correo no es válido."
            }
        }
    }

    init() {
        seedDefaultModeratorIfNeeded()
        restoreSessionIfNeeded()
    }

    // MARK: - Public API

    func signIn(email: String, password: String) async throws {
        await setLoading(true)
        defer { Task { await setLoading(false) } }

        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard let account = accountStore.find(where: { $0.profile.email.lowercased() == normalized }) else {
            await setError(AuthError.userNotFound)
            throw AuthError.userNotFound
        }
        guard PasswordHasher.verify(password: password, salt: account.salt, expectedHash: account.passwordHash) else {
            await setError(AuthError.invalidCredentials)
            throw AuthError.invalidCredentials
        }

        await activate(profile: account.profile)
    }

    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        await setLoading(true)
        defer { Task { await setLoading(false) } }

        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)

        guard normalized.contains("@"), normalized.contains(".") else {
            await setError(AuthError.invalidEmail)
            throw AuthError.invalidEmail
        }
        guard password.count >= 6 else {
            await setError(AuthError.weakPassword)
            throw AuthError.weakPassword
        }
        guard accountStore.find(where: { $0.profile.email.lowercased() == normalized }) == nil else {
            await setError(AuthError.emailAlreadyTaken)
            throw AuthError.emailAlreadyTaken
        }

        let salt = PasswordHasher.makeSalt()
        let hash = PasswordHasher.hash(password: password, salt: salt)

        let trimmedDisplay = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedUser = username.trimmingCharacters(in: .whitespaces)

        let profile = UserProfile(
            id: UUID(),
            email: normalized,
            username: trimmedUser.isEmpty ? normalized : trimmedUser,
            displayName: trimmedDisplay.isEmpty ? trimmedUser : trimmedDisplay,
            avatarUrl: nil,
            bio: nil,
            university: nil,
            reputation: 0,
            points: 0,
            studyStreak: 0,
            isModerator: normalized == "moderador@dailymath.com",
            createdAt: Date()
        )

        let account = LocalAccount(profile: profile, passwordHash: hash, salt: salt)
        accountStore.upsert(account)

        await activate(profile: profile)
    }

    func signOut() async throws {
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = nil
        }
        session.clearSession()
    }

    func resetPassword(email: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }

    func deleteAccount() async throws {
        await setLoading(true)
        defer { Task { await setLoading(false) } }

        if let user = await currentUserSnapshot() {
            accountStore.delete(id: user.id)
        }
        try await signOut()
    }

    /// Updates the persisted profile for the currently signed-in user (e.g. after points change).
    func updateCurrentProfile(_ mutation: (inout UserProfile) -> Void) {
        guard let user = currentUser,
              var account = accountStore.find(where: { $0.id == user.id }) else { return }
        var updated = account.profile
        mutation(&updated)
        account.profile = updated
        accountStore.upsert(account)
        Task { @MainActor in
            self.currentUser = updated
        }
    }

    // MARK: - Helpers

    @MainActor
    private func activate(profile: UserProfile) {
        self.currentUser = profile
        self.isAuthenticated = true
        self.errorMessage = nil
        session.saveSession(userId: profile.id.uuidString, isModerator: profile.isModerator)
    }

    @MainActor
    private func setLoading(_ value: Bool) {
        self.isLoading = value
    }

    @MainActor
    private func setError(_ error: Error) {
        self.errorMessage = error.localizedDescription
    }

    @MainActor
    private func currentUserSnapshot() -> UserProfile? { currentUser }

    private func restoreSessionIfNeeded() {
        guard session.isLoggedIn,
              let idString = session.userId,
              let id = UUID(uuidString: idString),
              let account = accountStore.find(where: { $0.id == id }) else {
            return
        }
        Task { @MainActor in
            self.currentUser = account.profile
            self.isAuthenticated = true
        }
    }

    private func seedDefaultModeratorIfNeeded() {
        let modEmail = "moderador@dailymath.com"
        guard accountStore.find(where: { $0.profile.email.lowercased() == modEmail }) == nil else { return }

        let salt = PasswordHasher.makeSalt()
        let hash = PasswordHasher.hash(password: "moderador123", salt: salt)
        let profile = UserProfile(
            id: UUID(),
            email: modEmail,
            username: "moderador",
            displayName: "Moderador Demo",
            avatarUrl: nil,
            bio: nil,
            university: "Universidad del Quindío",
            reputation: 100,
            points: 350,
            studyStreak: 4,
            isModerator: true,
            createdAt: Date()
        )
        accountStore.upsert(LocalAccount(profile: profile, passwordHash: hash, salt: salt))
    }
}
