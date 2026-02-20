import Foundation
import Combine

// MARK: - Exercise Model

struct Exercise: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    var title: String
    var category: String
    var statement: String
    var solution: String
    var imageUrl: String?
    var status: String
    var rejectionReason: String?
    var verifiedBy: UUID?
    var votesCount: Int
    var isPreloaded: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Joined data (optional, from queries)
    var author: UserProfile?
    
    var categoryEnum: AppConstants.Category? {
        AppConstants.Category(rawValue: category)
    }
    
    var statusEnum: AppConstants.ExerciseStatus? {
        AppConstants.ExerciseStatus(rawValue: status)
    }
    
    var isPending: Bool { status == "pending" }
    var isVerified: Bool { status == "verified" }
    
    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case title
        case category
        case statement
        case solution
        case imageUrl = "image_url"
        case status
        case rejectionReason = "rejection_reason"
        case verifiedBy = "verified_by"
        case votesCount = "votes_count"
        case isPreloaded = "is_preloaded"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author
    }
}

// MARK: - Create Exercise DTO

struct CreateExerciseDTO: Encodable {
    let authorId: UUID
    let title: String
    let category: String
    let statement: String
    let solution: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case authorId = "author_id"
        case title
        case category
        case statement
        case solution
        case imageUrl = "image_url"
    }
}
