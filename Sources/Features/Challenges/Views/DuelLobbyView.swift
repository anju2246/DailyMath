import SwiftUI

struct DuelLobbyView: View {
    var body: some View {
        List {
            Section(L10n.duelLobbySection) {
                Text(L10n.duelLobbyFlowEnabled)
                    .foregroundStyle(.secondary)
                Text(L10n.duelLobbyDescription)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.duelLobbySection)
        .navigationBarTitleDisplayMode(.inline)
    }
}
