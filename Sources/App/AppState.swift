import SwiftUI
import Combine

// MARK: - App State (Global Observable Object)

@MainActor
class AppState: ObservableObject {
    @Published var authService = AuthService()
    @Published var flashcardStore = FlashcardStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    var isAuthenticated: Bool { authService.isAuthenticated }
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
    }
}
