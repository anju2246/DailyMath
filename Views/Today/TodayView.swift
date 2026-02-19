import SwiftUI

// MARK: - Today View (Spaced Repetition Hub)

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header greeting
                VStack(alignment: .leading, spacing: 8) {
                    Text("¡Hola, \(appState.currentUser?.displayName ?? "")!")
                        .font(.title.bold())
                    
                    Text("Tus tarjetas de repaso del día")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Placeholder — will be replaced with flashcard list
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No hay tarjetas pendientes")
                        .font(.headline)
                    
                    Text("Agrega ejercicios a tu deck desde Explorar o crea los tuyos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .cardStyle()
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Hoy")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
