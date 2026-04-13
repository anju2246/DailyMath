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
                    Label(L10n.tabToday, systemImage: "calendar.badge.clock")
                }
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
                .tabItem {
                    Label(L10n.tabExplore, systemImage: "magnifyingglass")
                }
                .tag(MainTab.explore)
            
            NavigationStack(path: $navigation.createPath) {
                CreateExerciseView()
            }
                .tabItem {
                    Label(L10n.tabCreate, systemImage: "plus.circle.fill")
                }
                .tag(MainTab.create)
            
            NavigationStack(path: $navigation.agilityPath) {
                AgilityView()
            }
                .tabItem {
                    Label(L10n.tabAgility, systemImage: "brain")
                }
                .tag(MainTab.agility)

            NavigationStack(path: $navigation.challengesPath) {
                ChallengesHubView()
                    .navigationDestination(for: ChallengesRoute.self) { route in
                        switch route {
                        case .duelLobby:
                            DuelLobbyView()
                        }
                    }
            }
                .tabItem {
                    Label(L10n.tabChallenges, systemImage: "flag.checkered")
                }
                .tag(MainTab.challenges)
            
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
                .tabItem {
                    Label(L10n.tabProfile, systemImage: "person.circle")
                }
                .tag(MainTab.profile)
        }
        .tint(.dmPrimary)
        .onAppear {
            navigation.resetMainFeaturePaths()
        }
    }
}
