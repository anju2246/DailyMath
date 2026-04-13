import SwiftUI

struct ChallengesHubView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.challengesTitle)
                    .font(.largeTitle.bold())

                Text(L10n.challengesSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    navigation.pushChallenges(.duelLobby)
                } label: {
                    HStack {
                        Label(L10n.challengesEnterLobby, systemImage: "bolt.shield.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .primaryButton()
                }
            }
            .padding()
        }
        .navigationTitle(L10n.challengesTitle)
    }
}
