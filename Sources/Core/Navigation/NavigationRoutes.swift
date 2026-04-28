import Foundation

enum MainTab: Int, Hashable {
    case today = 0
    case explore = 1
    case create = 2
    case agility = 3
    case challenges = 4
    case leaderboard = 5
    case profile = 6
    case moderator = 7
}

enum AuthRoute: Hashable {
    case register
    case otp(email: String)
    case onboarding
}

enum AuthSheet: String, Identifiable {
    case forgotPassword

    var id: String { rawValue }
}

enum HomeSheet: String, Identifiable {
    case createFlashcard

    var id: String { rawValue }
}
enum HomeRoute: Hashable {
    case agility
    case flashcardQuiz
}

enum CommunityRoute: Hashable {
    case exerciseDetail(id: UUID)
}

enum ProfileRoute: Hashable {
    case editProfile
    case badges
    case stats
    case moderatorDashboard
}

enum AgilityRoute: Hashable {
    case summary
}

enum ChallengesRoute: Hashable {
    case duelLobby
    case activeDuel
    case duelResult(won: Bool)
}