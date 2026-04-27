import SwiftUI

// MARK: - Moderator Dashboard View

struct ModeratorDashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var pending: [Exercise] = []
    @State private var selected: Exercise?
    @State private var showAlert = false
    @State private var isLoading = false

    var body: some View {
        List {
            Section(header: Text(L10n.moderatorExercisesHeader)) {
                if pending.isEmpty {
                    Text("No hay ejercicios pendientes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pending) { exercise in
                        Button {
                            selected = exercise
                            showAlert = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .foregroundStyle(.orange)
                                    Text(exercise.title)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Text(exercise.statement)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.moderatorPanelTitle)
        .task { reloadPending() }
        .refreshable { reloadPending() }
        .alert(L10n.moderatorDetailTitle, isPresented: $showAlert) {
            Button(L10n.moderatorReject, role: .destructive) {
                if let selected { moderate(selected, status: .rejected) }
            }
            Button(L10n.moderatorApprove) {
                if let selected { moderate(selected, status: .verified) }
            }
            Button(L10n.commonCancel, role: .cancel) { }
        } message: {
            if let selected {
                Text(L10n.moderatorConfirmMsg(selected.title))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cerrar Sesión") {
                    Task { try? await appState.signOut() }
                }
                .foregroundStyle(.red)
            }
        }
    }

    private func reloadPending() {
        Task {
            let result = (try? await appState.exerciseRepository.fetchPendingExercises()) ?? []
            await MainActor.run { pending = result }
        }
    }

    private func moderate(_ exercise: Exercise, status: AppConstants.ExerciseStatus) {
        Task {
            try? await appState.exerciseRepository.moderateExercise(
                id: exercise.id,
                status: status,
                rejectionReason: nil
            )
            reloadPending()
        }
    }
}
