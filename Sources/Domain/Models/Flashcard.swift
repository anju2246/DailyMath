import Foundation
import Combine

// MARK: - Flashcard Model (User's Personal Deck)

struct Flashcard: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let exerciseId: UUID
    
    // SM-2 Algorithm fields
    var easinessFactor: Double
    var interval: Int             // Days until next review
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?
    var createdAt: Date
    
    // Joined data
    var exercise: Exercise?
    
    var isDueToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(nextReviewDate) || nextReviewDate < Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case easinessFactor = "easiness_factor"
        case interval
        case repetitions
        case nextReviewDate = "next_review_date"
        case lastReviewDate = "last_review_date"
        case createdAt = "created_at"
        case exercise
    }
}

// MARK: - SM-2 Review Quality

enum ReviewQuality: Int {
    case difficult = 0   // "Difícil" - complete failure
    case normal = 3      // "Normal" - correct with difficulty
    case easy = 5        // "Fácil" - perfect response
    
    var label: String {
        switch self {
        case .difficult: return "Difícil"
        case .normal: return "Normal"
        case .easy: return "Fácil"
        }
    }
    
    var icon: String {
        switch self {
        case .difficult: return "xmark.circle.fill"
        case .normal: return "checkmark.circle"
        case .easy: return "star.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .difficult: return "red"
        case .normal: return "orange"
        case .easy: return "green"
        }
    }
}
