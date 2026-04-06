import SwiftUI

struct CommunityExerciseDetailView: View {
    let exerciseId: UUID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label("Detalle de ejercicio", systemImage: "doc.text.magnifyingglass")
                    .font(.title3.bold())

                Text("ID: \(exerciseId.uuidString)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Este es el primer flujo conectado a CommunityRoute. Aquí se mostrará el enunciado, votos, comentarios y solución cuando se conecte el repositorio de comunidad.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Ejercicio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
