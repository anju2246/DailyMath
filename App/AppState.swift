import SwiftUI

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var authService = AuthService()
    
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
