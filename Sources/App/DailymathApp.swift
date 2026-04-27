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
                    ZStack {
                        Color.dmBackground.ignoresSafeArea()
                        VStack(spacing: 16) {
                            Image(systemName: "function")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.dmPrimary, Color.dmSuccess],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(L10n.appName)
                                .font(DMFont.largeTitle())
                                .foregroundStyle(.primary)
                            ProgressView()
                        }
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
