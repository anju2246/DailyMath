import Foundation

protocol FlashcardRepository: AnyObject {
    var flashcards: [QuizFlashcard] { get }
    var dueFlashcards: [QuizFlashcard] { get }
    var totalReviewedToday: Int { get }

    func add(_ card: QuizFlashcard)
    func delete(at offsets: IndexSet)
    func deleteById(_ id: UUID)
    func review(id: UUID, wasCorrect: Bool)
}
