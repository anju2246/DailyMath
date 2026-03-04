import SwiftUI
import Combine

// MARK: - Main Tab Navigation

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Hoy", systemImage: "calendar.badge.clock")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            CreateExerciseView()
                .tabItem {
                    Label("Crear", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            AgilityView()
                .tabItem {
                    Label("Agilidad", systemImage: "brain")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(4)
        }
        .tint(.dmPrimary)
    }
}
