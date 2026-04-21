import SwiftUI

struct CommunityExerciseDetailView: View {
    let exerciseId: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var showSolution = false
    @State private var userVote: Int = 0

    private var exercise: SampleExercise? { SampleExercises.find(id: exerciseId) }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            if let ex = exercise {
                ScrollView {
                    VStack(alignment: .leading, spacing: DMSpacing.md) {
                        categoryBadge(ex)
                        Text(ex.title).font(DMFont.title())
                        authorRow(ex)
                        statementCard(ex)
                        actionsRow(ex)
                        solutionCard(ex)
                    }
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.vertical, DMSpacing.md)
                }
            } else {
                VStack(spacing: DMSpacing.sm) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.dmTextSecondary)
                    Text("Ejercicio no encontrado").font(DMFont.headline())
                }
            }
        }
        .navigationTitle(exercise?.title ?? "Ejercicio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryBadge(_ ex: SampleExercise) -> some View {
        HStack(spacing: 4) {
            Image(systemName: ex.category.icon)
            Text(ex.category.displayName.uppercased())
        }
        .font(DMFont.caption2())
        .foregroundStyle(Color.dmPrimary)
        .padding(.horizontal, DMSpacing.sm)
        .padding(.vertical, 4)
        .background(Color.dmPrimary.opacity(0.12))
        .cornerRadius(DMRadius.pill)
    }

    private func authorRow(_ ex: SampleExercise) -> some View {
        HStack(spacing: DMSpacing.xs) {
            Image(systemName: "person.circle.fill")
                .foregroundStyle(Color.dmTextSecondary)
                .font(.title3)
            Text(ex.author).font(DMFont.callout())
            Text("•").foregroundStyle(Color.dmTextSecondary)
            Text("\(ex.comments) comentarios")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
        }
    }

    private func statementCard(_ ex: SampleExercise) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("ENUNCIADO").font(DMFont.caption2()).foregroundStyle(Color.dmTextSecondary)
            Text(ex.statement)
                .font(DMFont.body())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private func actionsRow(_ ex: SampleExercise) -> some View {
        HStack(spacing: DMSpacing.sm) {
            Button {
                userVote = userVote == 1 ? 0 : 1
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: userVote == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
                    Text("\(ex.votes + userVote)")
                }
                .font(DMFont.calloutEmphasized())
                .foregroundStyle(userVote == 1 ? Color.dmSuccess : Color.dmTextSecondary)
                .padding(.horizontal, DMSpacing.md)
                .padding(.vertical, DMSpacing.xs)
                .background(Color.dmSurface)
                .cornerRadius(DMRadius.pill)
            }
            Button { } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                    Text("\(ex.comments)")
                }
                .font(DMFont.calloutEmphasized())
                .foregroundStyle(Color.dmTextSecondary)
                .padding(.horizontal, DMSpacing.md)
                .padding(.vertical, DMSpacing.xs)
                .background(Color.dmSurface)
                .cornerRadius(DMRadius.pill)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "bookmark")
                    .foregroundStyle(Color.dmTextSecondary)
                    .padding(DMSpacing.xs)
                    .background(Color.dmSurface)
                    .clipShape(Circle())
            }
        }
    }

    private func solutionCard(_ ex: SampleExercise) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showSolution.toggle() }
            } label: {
                HStack {
                    Text("SOLUCIÓN").font(DMFont.caption2()).foregroundStyle(Color.dmTextSecondary)
                    Spacer()
                    Image(systemName: showSolution ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color.dmTextSecondary)
                        .font(.footnote)
                }
            }
            if showSolution {
                Text(ex.solution)
                    .font(DMFont.body())
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Button {
                    withAnimation { showSolution = true }
                } label: {
                    Text("Ver solución").primaryButton()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }
}
