import SwiftUI

@main
struct DailyMathApp: App {
    @StateObject private var appState = AppState()
    
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
                        Text("DailyMath")
                            .font(.largeTitle.bold())
                        ProgressView()
                    }
                } else if appState.isAuthenticated {
                    MainTabView()
                        .environmentObject(appState)
                } else {
                    LoginView()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthLoading)
        }
    }
}
