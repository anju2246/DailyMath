import SwiftUI
import Combine

@main
struct DailyMathApp: App {
    @StateObject private var statsManager = StatsManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                GameView()
                    .environmentObject(statsManager)
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
}