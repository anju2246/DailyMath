import SwiftUI

struct ProfileEditView: View {
    var body: some View {
        List {
            Section(L10n.profileTitle) {
                Text(L10n.profileEditPlaceholder)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.profileEdit)
    }
}

struct ProfileBadgesView: View {
    var body: some View {
        List {
            Section(L10n.profileBadges) {
                Text(L10n.profileBadgesPlaceholder)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.profileBadges)
    }
}

struct ProfileStatsView: View {
    var body: some View {
        List {
            Section(L10n.profileStats) {
                Text(L10n.profileStatsPlaceholder)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(L10n.profileStats)
    }
}
