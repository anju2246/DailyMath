import SwiftUI

// MARK: - Create Exercise View

struct CreateExerciseView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var title = ""
    @State private var selectedCategory: AppConstants.Category = .trigonometria
    @State private var statement = ""
    @State private var solution = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del ejercicio") {
                    TextField("Título", text: $title)
                    
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(AppConstants.Category.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("Enunciado") {
                    TextEditor(text: $statement)
                        .frame(minHeight: 100)
                }
                
                Section("Solución") {
                    TextEditor(text: $solution)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button {
                        // TODO: Submit exercise
                        showSuccess = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Publicar ejercicio", systemImage: "paperplane.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || statement.isEmpty || solution.isEmpty)
                } footer: {
                    Text("Tu ejercicio será revisado por un moderador antes de aparecer en el feed público.")
                }
            }
            .navigationTitle("Crear Ejercicio")
            .alert("¡Ejercicio publicado!", isPresented: $showSuccess) {
                Button("OK") {
                    clearForm()
                }
            } message: {
                Text("Tu ejercicio está pendiente de verificación por un moderador.")
            }
        }
    }
    
    private func clearForm() {
        title = ""
        statement = ""
        solution = ""
        selectedCategory = .trigonometria
    }
}
