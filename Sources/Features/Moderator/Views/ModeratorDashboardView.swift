import SwiftUI

// MARK: - Moderator Dashboard View

struct ModeratorDashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedExercise: String?
    @State private var showAlert = false
    
    // Simulación de ejercicios pendientes
    private let pendingExercises = [
        "Cálculo Integral: Área bajo la curva",
        "Álgebra Lineal: Determinante 3x3",
        "Trigonometría: Identidad Pitagórica"
    ]
    
    var body: some View {
        List {
            Section(header: Text("Ejercicios por Validar")) {
                ForEach(pendingExercises, id: \.self) { exercise in
                    Button {
                        selectedExercise = exercise
                        showAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundStyle(.orange)
                            Text(exercise)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Panel de Moderación")
        .alert("Detalle del Ejercicio", isPresented: $showAlert) {
            Button("Rechazar", role: .destructive) { }
            Button("Aprobar") { }
            Button("Cancelar", role: .cancel) { }
        } message: {
            if let exercise = selectedExercise {
                Text("¿Deseas validar el ejercicio: \"\(exercise)\"?")
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
}
