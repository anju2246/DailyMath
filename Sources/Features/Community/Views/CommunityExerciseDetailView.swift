import SwiftUI

struct CommunityExerciseDetailView: View {
    let exerciseId: UUID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(L10n.communityDetailTitle, systemImage: "doc.text.magnifyingglass")
                    .font(.title3.bold())

                Text(L10n.communityDetailId(exerciseId.uuidString))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(L10n.communityDetailPlaceholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(L10n.communityExerciseTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
