import SwiftUI

@MainActor
final class AppNavigationCoordinator: ObservableObject {
    @Published var selectedTab: MainTab = .today

    @Published var authPath = NavigationPath()
    @Published var authSheet: AuthSheet?

    @Published var homePath = NavigationPath()
    @Published var homeSheet: HomeSheet?
    @Published var homeFullScreen: HomeFullScreen?

    func pushAuth(_ route: AuthRoute) {
        authPath.append(route)
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
}