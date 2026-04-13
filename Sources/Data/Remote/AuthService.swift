import SwiftUI
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    enum AuthError: Error, LocalizedError {
        case notImplemented
        
        var errorDescription: String? {
            return L10n.authDemoError
        }
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run { isLoading = true }
        try await Task.sleep(nanoseconds: 0)
        await MainActor.run {
                self.currentUser = UserProfile(
                    id: UUID(),
                    email: email,
                    username: L10n.authDemoUsername,
                    displayName: L10n.authDemoDisplayName,
                    avatarUrl: nil,
                    bio: nil,
                    university: L10n.authDemoUniversity,
                    reputation: 150,
                    points: 1200,
                    studyStreak: 5,
                    isModerator: false,
                    createdAt: Date()
                )
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        try await signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        await MainActor.run { isLoading = true }
        try await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
    
    func resetPassword(email: String) async throws {
        // Mock success
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func deleteAccount() async throws {
        await MainActor.run { isLoading = true }
        try await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
}
