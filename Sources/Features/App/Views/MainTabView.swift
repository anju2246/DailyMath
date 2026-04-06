import SwiftUI

// MARK: - Main Tab Navigation

struct MainTabView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator
    
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            NavigationStack(path: $navigation.homePath) {
                TodayView()
            }
                .tabItem {
                    Label("Hoy", systemImage: "calendar.badge.clock")
                }
                .tag(MainTab.today)
            
            NavigationStack(path: $navigation.communityPath) {
                ExploreView()
            }
                .tabItem {
                    Label("Explorar", systemImage: "magnifyingglass")
                }
                .tag(MainTab.explore)
            
            NavigationStack(path: $navigation.createPath) {
                CreateExerciseView()
            }
                .tabItem {
                    Label("Crear", systemImage: "plus.circle.fill")
                }
                .tag(MainTab.create)
            
            NavigationStack(path: $navigation.agilityPath) {
                AgilityView()
            }
                .tabItem {
                    Label("Agilidad", systemImage: "brain")
                }
                .tag(MainTab.agility)
            
            NavigationStack(path: $navigation.profilePath) {
                ProfileView()
            }
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(MainTab.profile)
        }
        .tint(.dmPrimary)
        .onAppear {
            navigation.resetMainFeaturePaths()
        }
    }
}
