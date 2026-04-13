import SwiftUI

// MARK: - Main Tab Navigation

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            // MARK: - Standard User Tabs
            if !appState.isModerator {
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
                
                NavigationStack(path: $navigation.leaderboardPath) {
                    LeaderboardView()
                }
                .tabItem {
                    Label(L10n.tabLeaderboard, systemImage: "star.bubble.fill")
                }
                .tag(MainTab.leaderboard)
                
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
                
            } else {
                // MARK: - Moderator Specific Tabs
                NavigationStack(path: $navigation.moderatorPath) {
                    ModeratorDashboardView()
                }
                .tabItem {
                    Label(L10n.tabModerator, systemImage: "checkmark.seal.fill")
                }
                .tag(MainTab.moderator)
            }
            
            // MARK: - Common Tabs (Profile)
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
