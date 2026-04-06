import Foundation

@MainActor
protocol AuthRepository: AnyObject {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, username: String, displayName: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}
