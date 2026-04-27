import SwiftUI

// MARK: - Create Exercise View

struct CreateExerciseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var selectedCategory: AppConstants.Category = .trigonometria
    @State private var statement = ""
    @State private var solution = ""
    @State private var showSuccess = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(L10n.communityCreateInfoSection) {
                TextField(L10n.commonTitle, text: $title)

                Picker(L10n.commonCategory, selection: $selectedCategory) {
                    ForEach(AppConstants.Category.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category)
                    }
                }
            }

            Section(L10n.communityCreateStatement) {
                TextEditor(text: $statement)
                    .frame(minHeight: 100)
            }

            Section(L10n.communityCreateSolution) {
                TextEditor(text: $solution)
                    .frame(minHeight: 100)
            }

            Section {
                Button {
                    submit()
                } label: {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Label(L10n.communityPublish, systemImage: "paperplane.fill")
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                .disabled(!canSubmit || isSubmitting)
            } footer: {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                } else {
                    Text(L10n.communityPublishFooter)
                }
            }
        }
        .navigationTitle(L10n.communityCreateTitle)
        .alert(L10n.communityPublishedTitle, isPresented: $showSuccess) {
            Button(L10n.commonOk) {
                clearForm()
                dismiss()
            }
        } message: {
            Text("Tu ejercicio quedó pendiente de revisión por un moderador.")
        }
    }

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !statement.trimmingCharacters(in: .whitespaces).isEmpty &&
        !solution.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() {
        guard !isSubmitting else { return }
        guard let user = appState.currentUser else {
            errorMessage = "Inicia sesión para publicar ejercicios."
            return
        }
        isSubmitting = true
        errorMessage = nil
        let payload = CreateExerciseDTO(
            authorId: user.id,
            title: title.trimmingCharacters(in: .whitespaces),
            category: selectedCategory.rawValue,
            statement: statement.trimmingCharacters(in: .whitespaces),
            solution: solution.trimmingCharacters(in: .whitespaces),
            imageUrl: nil
        )
        Task {
            do {
                try await appState.exerciseRepository.createExercise(payload)
                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
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
