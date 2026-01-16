import SwiftUI
import Combine

@main
struct DailyMathApp: App {
    @StateObject private var statsManager = StatsManager()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(statsManager)
            } else {
                OnboardingView {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }
                .environmentObject(statsManager)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var statsManager: StatsManager
    
    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Jugar", systemImage: "gamecontroller")
                }
            
            StatsView(statsManager: statsManager)
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
        }
    }
}