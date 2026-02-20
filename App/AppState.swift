import SwiftUI
import Combine

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var authService = AuthService()
    @Published var flashcardStore = FlashcardStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Forward AuthService changes so SwiftUI sees them
        authService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Forward FlashcardStore changes
        flashcardStore.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    var currentUser: UserProfile? {
        authService.currentUser
    }
    
    var isModerator: Bool {
        authService.currentUser?.isModerator ?? false
    }
}
