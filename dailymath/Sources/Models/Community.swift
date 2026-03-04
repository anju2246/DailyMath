import Foundation
import Combine

// MARK: - Comment Model

struct Comment: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let exerciseId: UUID
    var content: String
    var createdAt: Date
    
    // Joined data
    var user: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case content
        case createdAt = "created_at"
        case user
    }
}

// MARK: - Vote Model

struct Vote: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let exerciseId: UUID
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case createdAt = "created_at"
    }
}

// MARK: - User Badge Model

struct UserBadge: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let badgeKey: String
    var earnedAt: Date
    
    var badge: AppConstants.BadgeKey? {
        AppConstants.BadgeKey(rawValue: badgeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case badgeKey = "badge_key"
        case earnedAt = "earned_at"
    }
}

// MARK: - Notification Model

struct AppNotification: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var type: String
    var title: String
    var body: String?
    var referenceId: UUID?
    var isRead: Bool
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case body
        case referenceId = "reference_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
