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
                question: "¿Cuál es la derivada de sin(x)?",
                correctAnswer: "cos(x)",
                wrongAnswers: ["-cos(x)", "tan(x)", "-sin(x)"],
                category: "calculo_diferencial"
            ),
            QuizFlashcard(
                question: "¿Cuánto es sen(π/2)?",
                correctAnswer: "1",
                wrongAnswers: ["0", "-1", "√2/2"],
                category: "trigonometria"
            ),
            QuizFlashcard(
                question: "¿Cuál es la integral de 1/x dx?",
                correctAnswer: "ln|x| + C",
                wrongAnswers: ["x² + C", "1/x² + C", "eˣ + C"],
                category: "calculo_integral"
            ),
            QuizFlashcard(
                question: "¿Cuál es el determinante de una matriz identidad 3×3?",
                correctAnswer: "1",
                wrongAnswers: ["0", "3", "-1"],
                category: "algebra_lineal"
            ),
            QuizFlashcard(
                question: "Si P(A) = 0.3 y P(B) = 0.5 son independientes, ¿cuánto es P(A∩B)?",
                correctAnswer: "0.15",
                wrongAnswers: ["0.80", "0.20", "0.35"],
                category: "probabilidad"
            )
        ]
        
        flashcards = samples
        save()
    }
}
