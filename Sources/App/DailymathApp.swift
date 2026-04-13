import SwiftUI

@main
struct DailyMathApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var navigation = AppNavigationCoordinator()
    
    init() {
        NotificationService.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthLoading {
                    // Splash screen
                    VStack(spacing: 16) {
                        Image(systemName: "function")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(L10n.appName)
                            .font(.largeTitle.bold())
                        ProgressView()
                    }
                } else if appState.isAuthenticated {
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(navigation)
                } else {
                    LoginView()
                        .environmentObject(appState)
                        .environmentObject(navigation)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthLoading)
        }
    }
}
