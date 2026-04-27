import SwiftUI

// MARK: - Create Exercise View

struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedCategory: AppConstants.Category = .trigonometria
    @State private var statement = ""
    @State private var solution = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
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
                        // TODO: Submit exercise
                        showSuccess = true
                    } label: {
                        HStack {
                            Spacer()
                            Label(L10n.communityPublish, systemImage: "paperplane.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || statement.isEmpty || solution.isEmpty)
                } footer: {
                    Text(L10n.communityPublishFooter)
                }
            }
            .navigationTitle(L10n.communityCreateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.commonCancel) { dismiss() }
                }
            }
            .alert(L10n.communityPublishedTitle, isPresented: $showSuccess) {
                Button(L10n.commonOk) {
                    clearForm()
                    dismiss()
                }
            } message: {
                Text(L10n.communityPublishedMessage)
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
