import SwiftUI

struct ChallengesHubView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Desafíos")
                    .font(.largeTitle.bold())

                Text("Compite en duelos 1v1 y torneos semanales.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    navigation.pushChallenges(.duelLobby)
                } label: {
                    HStack {
                        Label("Entrar a lobby 1v1", systemImage: "bolt.shield.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .primaryButton()
                }
            }
            .padding()
        }
        .navigationTitle("Desafíos")
    }
}
