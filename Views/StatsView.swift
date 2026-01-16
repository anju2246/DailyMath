import SwiftUI

// MARK: - Vista de Estadísticas
struct StatsView: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        List {
            Section("General") {
                HStack {
                    Text("Problemas resueltos")
                    Spacer()
                    Text("\(statsManager.stats.totalProblems)")
                        .bold()
                }
                HStack {
                    Text("Respuestas correctas")
                    Spacer()
                    Text("\(statsManager.stats.correctAnswers)")
                        .bold()
                        .foregroundColor(.green)
                }
                HStack {
                    Text("Precisión")
                    Spacer()
                    Text("\(Int(statsManager.stats.accuracy * 100))%")
                        .bold()
                }
                HStack {
                    Text("Tiempo promedio")
                    Spacer()
                    Text(String(format: "%.1fs", statsManager.stats.averageTime))
                        .bold()
                }
            }
            
            Section("Por operación") {
                ForEach(Array(statsManager.stats.accuracyByType.keys.sorted()), id: \.self) { op in
                    HStack {
                        Text(op)
                            .font(.title2)
                        Spacer()
                        Text("\(Int((statsManager.stats.accuracyByType[op] ?? 0) * 100))%")
                            .bold()
                        Text("(\(statsManager.stats.problemsByType[op] ?? 0))")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                Button("Reiniciar estadísticas", role: .destructive) {
                    statsManager.resetStats()
                }
            }
        }
    }
}