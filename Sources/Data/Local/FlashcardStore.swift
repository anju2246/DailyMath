import Foundation
import SwiftUI
import Combine

// MARK: - Quiz Flashcard Model

struct QuizFlashcard: Codable, Identifiable {
    let id: UUID
    var question: String
    var correctAnswer: String
    var wrongAnswers: [String]  // 3 wrong options
    var category: String
    
    // SM-2 fields
    var easinessFactor: Double
    var interval: Int             // Days until next review
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?
    var createdAt: Date
    
    var isDueToday: Bool {
        Calendar.current.isDateInToday(nextReviewDate) || nextReviewDate < Date()
    }
    
    /// Returns all 4 options shuffled
    var shuffledOptions: [String] {
        var options = wrongAnswers
        options.append(correctAnswer)
        return options.shuffled()
    }
    
    init(
        id: UUID = UUID(),
        question: String,
        correctAnswer: String,
        wrongAnswers: [String],
        category: String = "general",
        easinessFactor: Double = 2.5,
        interval: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.correctAnswer = correctAnswer
        self.wrongAnswers = wrongAnswers
        self.category = category
        self.easinessFactor = easinessFactor
        self.interval = interval
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.lastReviewDate = lastReviewDate
        self.createdAt = createdAt
    }
}

// MARK: - FlashcardStore

class FlashcardStore: ObservableObject {
    @Published var flashcards: [QuizFlashcard] = []
    
    private let storageKey = "dailymath_flashcards"
    
    var dueFlashcards: [QuizFlashcard] {
        flashcards.filter { $0.isDueToday }
    }
    
    var totalReviewedToday: Int {
        flashcards.filter { card in
            guard let lastReview = card.lastReviewDate else { return false }
            return Calendar.current.isDateInToday(lastReview)
        }.count
    }
    
    init() {
        load()
        if flashcards.isEmpty {
            loadSampleFlashcards()
        }
    }
    
    // MARK: - CRUD
    
    func add(_ card: QuizFlashcard) {
        flashcards.append(card)
        save()
    }
    
    func delete(at offsets: IndexSet) {
        flashcards.remove(atOffsets: offsets)
        save()
    }
    
    func deleteById(_ id: UUID) {
        flashcards.removeAll { $0.id == id }
        save()
    }
    
    // MARK: - Review (SM-2)
    
    func review(id: UUID, wasCorrect: Bool) {
        guard let index = flashcards.firstIndex(where: { $0.id == id }) else { return }
        
        let card = flashcards[index]
        let quality = wasCorrect ? 4 : 1  // SM-2 quality: 4=correct, 1=wrong
        
        let result = SM2Algorithm.calculate(
            quality: quality,
            repetitions: card.repetitions,
            easinessFactor: card.easinessFactor,
            interval: card.interval
        )
        
        flashcards[index].easinessFactor = result.easinessFactor
        flashcards[index].interval = result.interval
        flashcards[index].repetitions = result.repetitions
        flashcards[index].nextReviewDate = result.nextReviewDate
        flashcards[index].lastReviewDate = Date()
        
        save()
    }
    
    // MARK: - Persistence
    
    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(flashcards) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let loaded = try? decoder.decode([QuizFlashcard].self, from: data) {
            flashcards = loaded
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleFlashcards() {
        let samples: [QuizFlashcard] = [
            QuizFlashcard(
                question: L10n.sampleQuestion1,
                correctAnswer: L10n.sampleQuestion1Correct,
                wrongAnswers: [L10n.sampleQuestion1Wrong1, L10n.sampleQuestion1Wrong2, L10n.sampleQuestion1Wrong3],
                category: "calculo_diferencial"
            ),
            QuizFlashcard(
                question: L10n.sampleQuestion2,
                correctAnswer: L10n.sampleQuestion2Correct,
                wrongAnswers: [L10n.sampleQuestion2Wrong1, L10n.sampleQuestion2Wrong2, L10n.sampleQuestion2Wrong3],
                category: "trigonometria"
            ),
            QuizFlashcard(
                question: L10n.sampleQuestion3,
                correctAnswer: L10n.sampleQuestion3Correct,
                wrongAnswers: [L10n.sampleQuestion3Wrong1, L10n.sampleQuestion3Wrong2, L10n.sampleQuestion3Wrong3],
                category: "calculo_integral"
            ),
            QuizFlashcard(
                question: L10n.sampleQuestion4,
                correctAnswer: L10n.sampleQuestion4Correct,
                wrongAnswers: [L10n.sampleQuestion4Wrong1, L10n.sampleQuestion4Wrong2, L10n.sampleQuestion4Wrong3],
                category: "algebra_lineal"
            ),
            QuizFlashcard(
                question: L10n.sampleQuestion5,
                correctAnswer: L10n.sampleQuestion5Correct,
                wrongAnswers: [L10n.sampleQuestion5Wrong1, L10n.sampleQuestion5Wrong2, L10n.sampleQuestion5Wrong3],
                category: "probabilidad"
            )
        ]
        
        flashcards = samples
        save()
    }
}
