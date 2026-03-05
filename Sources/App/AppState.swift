import SwiftUI
import Combine

// MARK: - App State (Global Observable Object)

@MainActor
class AppState: ObservableObject {
    @Published var authService = AuthService()
    @Published var flashcardStore = FlashcardStore()
    /// Mirror of the authentication state for easier bindings/publishing.
    @Published private(set) var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var currentUser: UserProfile? { authService.currentUser }
    var isModerator: Bool { authService.currentUser?.isModerator ?? false }
    
    init() {
        // Forward AuthService changes so SwiftUI re-evaluates the view tree
        authService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // also keep the simple Bool up-to-date
        authService.$isAuthenticated
            .receive(on: RunLoop.main)
            .assign(to: &$isAuthenticated)
    }
}
