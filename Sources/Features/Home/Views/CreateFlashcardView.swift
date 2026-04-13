import SwiftUI

// MARK: - Create Flashcard View

struct CreateFlashcardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var question = ""
    @State private var correctAnswer = ""
    @State private var wrongAnswer1 = ""
    @State private var wrongAnswer2 = ""
    @State private var wrongAnswer3 = ""
    @State private var selectedCategory: AppConstants.Category = .calculoDiferencial
    @State private var showSaved = false
    
    private var isFormValid: Bool {
        !question.isEmpty &&
        !correctAnswer.isEmpty &&
        !wrongAnswer1.isEmpty &&
        !wrongAnswer2.isEmpty &&
        !wrongAnswer3.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Category
                Section(L10n.flashcardCategorySection) {
                    Picker(L10n.commonCategory, selection: $selectedCategory) {
                        ForEach(AppConstants.Category.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Question
                Section(L10n.flashcardQuestionSection) {
                    TextField(L10n.flashcardQuestionPlaceholder, text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Correct answer
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        TextField(L10n.flashcardCorrectAnswerPlaceholder, text: $correctAnswer)
                    }
                } header: {
                    Label(L10n.flashcardCorrectAnswerHeader, systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
                
                // Wrong answers
                Section {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField(L10n.flashcardWrongOption1, text: $wrongAnswer1)
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField(L10n.flashcardWrongOption2, text: $wrongAnswer2)
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField(L10n.flashcardWrongOption3, text: $wrongAnswer3)
                    }
                } header: {
                    Label(L10n.flashcardWrongAnswersHeader, systemImage: "xmark.seal.fill")
                        .foregroundStyle(.red)
                }
                
                // Save
                Section {
                    Button {
                        saveFlashcard()
                    } label: {
                        HStack {
                            Spacer()
                            Label(L10n.flashcardSave, systemImage: "plus.circle.fill")
                                .font(.headline.bold())
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(L10n.flashcardNewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.commonCancel) { dismiss() }
                }
            }
            .alert(L10n.flashcardSavedTitle, isPresented: $showSaved) {
                Button(L10n.commonCreateAnother) { resetForm() }
                Button(L10n.commonDone) { dismiss() }
            } message: {
                Text(L10n.flashcardSavedMessage)
            }
        }
    }
    
    private func saveFlashcard() {
        let card = QuizFlashcard(
            question: question,
            correctAnswer: correctAnswer,
            wrongAnswers: [wrongAnswer1, wrongAnswer2, wrongAnswer3],
            category: selectedCategory.rawValue
        )
        appState.flashcardStore.add(card)
        showSaved = true
    }
    
    private func resetForm() {
        question = ""
        correctAnswer = ""
        wrongAnswer1 = ""
        wrongAnswer2 = ""
        wrongAnswer3 = ""
    }
}
