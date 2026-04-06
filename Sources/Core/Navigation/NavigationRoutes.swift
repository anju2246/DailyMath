import Foundation

enum MainTab: Int, Hashable {
    case today = 0
    case explore = 1
    case create = 2
    case agility = 3
    case profile = 4
}

enum AuthRoute: Hashable {
    case register
}

enum AuthSheet: String, Identifiable {
    case forgotPassword

    var id: String { rawValue }
}

enum HomeSheet: String, Identifiable {
    case createFlashcard

    var id: String { rawValue }
}

enum HomeFullScreen: String, Identifiable {
    case flashcardQuiz

    var id: String { rawValue }
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
}