import SwiftUI

struct DuelLobbyView: View {
    var body: some View {
        List {
            Section("Lobby 1v1") {
                Text("Flujo base de ChallengesRoute activado.")
                    .foregroundStyle(.secondary)
                Text("Desde aquí se conectarán crear/unirse a duelo y matchmaking realtime.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Lobby 1v1")
        .navigationBarTitleDisplayMode(.inline)
    }
}
