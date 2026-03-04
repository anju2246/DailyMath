import Foundation
import Combine

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var email: String
    var username: String
    var displayName: String?
    var avatarUrl: String?
    var bio: String?
    var university: String?
    var reputation: Int
    var points: Int = 0
    var studyStreak: Int = 0
    var isModerator: Bool
    var createdAt: Date
    
    var userLevel: AppConstants.UserLevel {
        AppConstants.UserLevel.level(for: points)
    }
}
