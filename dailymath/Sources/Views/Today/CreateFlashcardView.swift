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
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(AppConstants.Category.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Question
                Section("Pregunta") {
                    TextField("Ej: ¿Cuál es la derivada de x²?", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Correct answer
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        TextField("Respuesta correcta", text: $correctAnswer)
                    }
                } header: {
                    Label("Respuesta Correcta", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
                
                // Wrong answers
                Section {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField("Opción incorrecta 1", text: $wrongAnswer1)
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField("Opción incorrecta 2", text: $wrongAnswer2)
                    }
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        TextField("Opción incorrecta 3", text: $wrongAnswer3)
                    }
                } header: {
                    Label("Opciones Incorrectas", systemImage: "xmark.seal.fill")
                        .foregroundStyle(.red)
                }
                
                // Save
                Section {
                    Button {
                        saveFlashcard()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Guardar Flashcard", systemImage: "plus.circle.fill")
                                .font(.headline.bold())
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Nueva Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert("¡Flashcard Guardada!", isPresented: $showSaved) {
                Button("Crear otra") { resetForm() }
                Button("Listo") { dismiss() }
            } message: {
                Text("Tu flashcard fue agregada al deck. La verás en tu próximo quiz.")
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
