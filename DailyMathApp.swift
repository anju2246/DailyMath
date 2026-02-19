import SwiftUI

@main
struct DailyMathApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.authService.isLoading {
                    // Splash / Loading
                    ZStack {
                        Color(.systemBackground)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "function")
                                .font(.system(size: 64))
                                .foregroundStyle(.tint)
                            
                            Text("DailyMath")
                                .font(.largeTitle.bold())
                            
                            ProgressView()
                                .padding(.top, 8)
                        }
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
            .animation(.easeInOut(duration: 0.3), value: appState.authService.isLoading)
        }
    }
}