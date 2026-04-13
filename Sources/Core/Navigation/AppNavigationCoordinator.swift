import SwiftUI

@MainActor
final class AppNavigationCoordinator: ObservableObject {
    @Published var selectedTab: MainTab = .today

    @Published var authPath = NavigationPath()
    @Published var authSheet: AuthSheet?

    @Published var homePath = NavigationPath()
    @Published var homeSheet: HomeSheet?
    @Published var homeFullScreen: HomeFullScreen?

    @Published var communityPath = NavigationPath()
    @Published var createPath = NavigationPath()
    @Published var agilityPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    @Published var challengesPath = NavigationPath()
    @Published var leaderboardPath = NavigationPath()
    @Published var moderatorPath = NavigationPath()

    func pushAuth(_ route: AuthRoute) {
        authPath.append(route)
    }

    func pushCommunity(_ route: CommunityRoute) {
        communityPath.append(route)
    }

    func pushProfile(_ route: ProfileRoute) {
        profilePath.append(route)
    }

    func pushChallenges(_ route: ChallengesRoute) {
        challengesPath.append(route)
    }

    func resetAuth() {
        authPath = NavigationPath()
        authSheet = nil
    }

    func presentAuthSheet(_ sheet: AuthSheet) {
        authSheet = sheet
    }

    func dismissAuthSheet() {
        authSheet = nil
    }

    func presentHomeSheet(_ sheet: HomeSheet) {
        homeSheet = sheet
    }

    func dismissHomeSheet() {
        homeSheet = nil
    }

    func presentHomeFullScreen(_ screen: HomeFullScreen) {
        homeFullScreen = screen
    }

    func dismissHomeFullScreen() {
        homeFullScreen = nil
    }

    func resetMainFeaturePaths() {
        homePath = NavigationPath()
        communityPath = NavigationPath()
        createPath = NavigationPath()
        agilityPath = NavigationPath()
        profilePath = NavigationPath()
        challengesPath = NavigationPath()
        leaderboardPath = NavigationPath()
        moderatorPath = NavigationPath()
    }
}