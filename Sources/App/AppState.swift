import SwiftUI
import Combine

// MARK: - App State (Global Observable Object)

@MainActor
class AppState: ObservableObject {
    let authService: any AuthRepository
    let flashcardStore: any FlashcardRepository
    /// Mirror of the authentication state for easier bindings/publishing.
    @Published private(set) var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var currentUser: UserProfile? { authService.currentUser }
    var isModerator: Bool { authService.currentUser?.isModerator ?? false }
    var isAuthLoading: Bool { authService.isLoading }

    init(
        authService: any AuthRepository = AuthService(),
        flashcardStore: any FlashcardRepository = FlashcardStore()
    ) {
        self.authService = authService
        self.flashcardStore = flashcardStore

        // Forward AuthService changes so SwiftUI re-evaluates the view tree
        authService.objectWillChangePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Forward FlashcardRepository changes for views that render deck state.
        flashcardStore.objectWillChangePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // also keep the simple Bool up-to-date
        authService.isAuthenticatedPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isAuthenticated)
    }

    func signOut() async throws {
        try await authService.signOut()
    }

    func deleteAccount() async throws {
        try await authService.deleteAccount()
    }
}
