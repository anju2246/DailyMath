@main
struct MathTrainingApp: App {
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

// MARK: - Preview
struct MathTrainingApp_Previews: PreviewProvider {
    static var previews: some View {
        MathTrainingApp()
    }
}