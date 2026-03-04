import Foundation
import Combine

// MARK: - Duel Model

struct Duel: Codable, Identifiable {
    let id: UUID
    let player1Id: UUID
    var player2Id: UUID?
    var category: String?
    var status: String
    var player1Score: Int
    var player2Score: Int
    var winnerId: UUID?
    var currentQuestion: Int
    var totalQuestions: Int
    var inviteCode: String?
    var createdAt: Date
    var finishedAt: Date?
    
    // Joined data
    var player1: UserProfile?
    var player2: UserProfile?
    
    var statusEnum: AppConstants.DuelStatus? {
        AppConstants.DuelStatus(rawValue: status)
    }
    
    var isWaiting: Bool { status == "waiting" }
    var isActive: Bool { status == "active" }
    var isFinished: Bool { status == "finished" }
    
    enum CodingKeys: String, CodingKey {
        case id
        case player1Id = "player1_id"
        case player2Id = "player2_id"
        case category
        case status
        case player1Score = "player1_score"
        case player2Score = "player2_score"
        case winnerId = "winner_id"
        case currentQuestion = "current_question"
        case totalQuestions = "total_questions"
        case inviteCode = "invite_code"
        case createdAt = "created_at"
        case finishedAt = "finished_at"
        case player1
        case player2
    }
}

// MARK: - Duel Question Model

struct DuelQuestion: Codable, Identifiable {
    let id: UUID
    let duelId: UUID
    var questionIndex: Int
    var num1: Int
    var num2: Int
    var operation: String
    var correctAnswer: Int
    var player1Answer: Int?
    var player1TimeMs: Int?
    var player2Answer: Int?
    var player2TimeMs: Int?
    
    var displayText: String {
        "\(num1) \(operation) \(num2) = ?"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case duelId = "duel_id"
        case questionIndex = "question_index"
        case num1
        case num2
        case operation
        case correctAnswer = "correct_answer"
        case player1Answer = "player1_answer"
        case player1TimeMs = "player1_time_ms"
        case player2Answer = "player2_answer"
        case player2TimeMs = "player2_time_ms"
    }
}

// MARK: - Tournament Model

struct Tournament: Codable, Identifiable {
    let id: UUID
    var name: String
    var category: String?
    var startDate: Date
    var endDate: Date
    var status: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case startDate = "start_date"
        case endDate = "end_date"
        case status
        case createdAt = "created_at"
    }
}

// MARK: - Tournament Participant

struct TournamentParticipant: Codable, Identifiable {
    let id: UUID
    let tournamentId: UUID
    let userId: UUID
    var score: Int
    var duelsWon: Int
    var duelsPlayed: Int
    
    // Joined data
    var user: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tournamentId = "tournament_id"
        case userId = "user_id"
        case score
        case duelsWon = "duels_won"
        case duelsPlayed = "duels_played"
        case user
    }
}
