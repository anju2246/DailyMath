import Foundation
import Combine

@MainActor
protocol AuthRepository: AnyObject {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    var isAuthenticatedPublisher: AnyPublisher<Bool, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    var objectWillChangePublisher: AnyPublisher<Void, Never> { get }

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, username: String, displayName: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}
