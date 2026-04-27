import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            if !appState.isModerator {
                NavigationStack(path: $navigation.homePath) {
                    TodayView()
                }
                .tabItem { Label("Hoy", systemImage: "calendar") }
                .tag(MainTab.today)

                NavigationStack(path: $navigation.communityPath) {
                    ExploreView()
                        .navigationDestination(for: CommunityRoute.self) { route in
                            switch route {
                            case let .exerciseDetail(id):
                                CommunityExerciseDetailView(exerciseId: id)
                            }
                        }
                }
                .tabItem { Label("Explorar", systemImage: "magnifyingglass") }
                .tag(MainTab.explore)

                NavigationStack(path: $navigation.challengesPath) {
                    ChallengesHubView()
                        .navigationDestination(for: ChallengesRoute.self) { route in
                            switch route {
                            case .duelLobby:
                                DuelLobbyView()
                            case .activeDuel:
                                ActiveDuelView()
                            case .duelResult(let won):
                                DuelResultView(won: won)
                            }
                        }
                }
                .tabItem { Label("Combatir", systemImage: "flag.checkered") }
                .tag(MainTab.challenges)

                NavigationStack(path: $navigation.agilityPath) {
                    AgilityView()
                }
                .tabItem { Label("Agilidad", systemImage: "brain.head.profile") }
                .tag(MainTab.agility)

            } else {
                NavigationStack(path: $navigation.moderatorPath) {
                    ModeratorDashboardView()
                }
                .tabItem { Label(L10n.tabModerator, systemImage: "checkmark.seal.fill") }
                .tag(MainTab.moderator)
            }

            NavigationStack(path: $navigation.profilePath) {
                ProfileView()
                    .navigationDestination(for: ProfileRoute.self) { route in
                        switch route {
                        case .editProfile:
                            ProfileEditView()
                        case .badges:
                            ProfileBadgesView()
                        case .stats:
                            ProfileStatsView()
                        case .moderatorDashboard:
                            ModeratorDashboardView()
                        }
                    }
            }
            .tabItem { Label("Perfil", systemImage: "person.fill") }
            .tag(MainTab.profile)
        }
        .tint(Color.dmPrimary)
        .onAppear {
            navigation.resetMainFeaturePaths()
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.dmSurface)
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
