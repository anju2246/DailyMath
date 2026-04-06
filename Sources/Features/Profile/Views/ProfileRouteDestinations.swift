import SwiftUI

struct ProfileEditView: View {
    var body: some View {
        List {
            Section("Perfil") {
                Text("Pantalla base de edición de perfil")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Editar perfil")
    }
}

struct ProfileBadgesView: View {
    var body: some View {
        List {
            Section("Insignias") {
                Text("Pantalla base de insignias")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Insignias")
    }
}

struct ProfileStatsView: View {
    var body: some View {
        List {
            Section("Estadísticas") {
                Text("Pantalla base de estadísticas")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Estadísticas")
    }
}

struct ModeratorDashboardView: View {
    var body: some View {
        List {
            Section("Moderación") {
                Text("Pantalla base del panel de moderación")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Moderador")
    }
}
