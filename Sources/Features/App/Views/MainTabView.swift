import SwiftUI
import Combine

// MARK: - Main Tab Navigation

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            TodayView()
                .tabItem {
                    Label("Hoy", systemImage: "calendar.badge.clock")
                }
                .tag(MainTab.today)
            
            ExploreView()
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .tag(MainTab.explore)
            
            CreateExerciseView()
                .tabItem {
                    Label("Crear", systemImage: "plus.circle.fill")
                }
                .tag(MainTab.create)
            
            AgilityView()
                .tabItem {
                    Label("Agilidad", systemImage: "brain")
                }
                .tag(MainTab.agility)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(MainTab.profile)
        }
        .tint(.dmPrimary)
    }
}
