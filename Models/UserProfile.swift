import Foundation

// MARK: - User Profile Model

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var email: String
    var university: String?
    var avatarUrl: String?
    var points: Int
    var level: Int
    var studyStreak: Int
    var lastStudyDate: Date?
    var role: String
    var createdAt: Date
    
    var userLevel: AppConstants.UserLevel {
        AppConstants.UserLevel.level(for: points)
    }
    
    var isModerator: Bool {
        role == "moderator"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case university
        case avatarUrl = "avatar_url"
        case points
        case level
        case studyStreak = "study_streak"
        case lastStudyDate = "last_study_date"
        case role
        case createdAt = "created_at"
    }
}
