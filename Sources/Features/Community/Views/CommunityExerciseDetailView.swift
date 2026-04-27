import SwiftUI

struct CommunityExerciseDetailView: View {
    let exerciseId: UUID
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var showSolution = false
    @State private var newComment: String = ""
    @State private var isSendingComment = false
    @FocusState private var commentFieldFocused: Bool

    private var exercise: Exercise? { appState.exerciseRepository.find(id: exerciseId) }
    private var hasVoted: Bool { appState.communityRepository.hasVoted(exerciseId: exerciseId) }
    private var comments: [Comment] { appState.communityRepository.commentsByExercise[exerciseId] ?? [] }

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
                        commentsSection(ex)
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

    private func categoryBadge(_ ex: Exercise) -> some View {
        HStack(spacing: 4) {
            if let category = ex.categoryEnum {
                Image(systemName: category.icon)
                Text(category.displayName.uppercased())
            } else {
                Text(ex.category.uppercased())
            }
        }
        .font(DMFont.caption2())
        .foregroundStyle(Color.dmPrimary)
        .padding(.horizontal, DMSpacing.sm)
        .padding(.vertical, 4)
        .background(Color.dmPrimary.opacity(0.12))
        .cornerRadius(DMRadius.pill)
    }

    private func authorRow(_ ex: Exercise) -> some View {
        let authorName = ex.author?.displayName
            ?? ex.author?.username
            ?? (ex.isPreloaded ? "DailyMath" : "Anónimo")
        return HStack(spacing: DMSpacing.xs) {
            Image(systemName: "person.circle.fill")
                .foregroundStyle(Color.dmTextSecondary)
                .font(.title3)
            Text(authorName).font(DMFont.callout())
            Text("•").foregroundStyle(Color.dmTextSecondary)
            Text("\(comments.count) comentarios")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
        }
    }

    private func statementCard(_ ex: Exercise) -> some View {
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

    private func actionsRow(_ ex: Exercise) -> some View {
        HStack(spacing: DMSpacing.sm) {
            Button {
                Task { try? await appState.communityRepository.vote(exerciseId: ex.id) }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: hasVoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                    Text("\(ex.votesCount)")
                }
                .font(DMFont.calloutEmphasized())
                .foregroundStyle(hasVoted ? Color.dmSuccess : Color.dmTextSecondary)
                .padding(.horizontal, DMSpacing.md)
                .padding(.vertical, DMSpacing.xs)
                .background(Color.dmSurface)
                .cornerRadius(DMRadius.pill)
            }
            Button {
                commentFieldFocused = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                    Text("\(comments.count)")
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

    private func solutionCard(_ ex: Exercise) -> some View {
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

    private func commentsSection(_ ex: Exercise) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            Text("COMENTARIOS")
                .font(DMFont.caption2())
                .foregroundStyle(Color.dmTextSecondary)
            if comments.isEmpty {
                Text("Sé el primero en comentar.")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmTextSecondary)
            } else {
                VStack(spacing: DMSpacing.sm) {
                    ForEach(comments) { comment in
                        commentRow(comment)
                    }
                }
            }
            HStack(spacing: DMSpacing.xs) {
                TextField("Escribe un comentario...", text: $newComment, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($commentFieldFocused)
                    .padding(.horizontal, DMSpacing.sm)
                    .padding(.vertical, DMSpacing.xs)
                    .background(Color.dmBackground)
                    .cornerRadius(DMRadius.md)
                Button {
                    sendComment(exerciseId: ex.id)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white)
                        .padding(DMSpacing.xs)
                        .background(canSendComment ? Color.dmPrimary : Color.dmTextSecondary)
                        .clipShape(Circle())
                }
                .disabled(!canSendComment || isSendingComment)
            }
            .padding(.top, DMSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private func commentRow(_ comment: Comment) -> some View {
        let displayName = comment.user?.displayName
            ?? comment.user?.username
            ?? "Usuario"
        return HStack(alignment: .top, spacing: DMSpacing.xs) {
            Image(systemName: "person.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.dmTextSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(DMFont.calloutEmphasized())
                    .foregroundStyle(.primary)
                Text(comment.content)
                    .font(DMFont.footnote())
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, DMSpacing.xxs)
    }

    private var canSendComment: Bool {
        !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendComment(exerciseId: UUID) {
        guard canSendComment, !isSendingComment else { return }
        isSendingComment = true
        let content = newComment
        Task {
            try? await appState.communityRepository.createComment(exerciseId: exerciseId, content: content)
            await MainActor.run {
                newComment = ""
                isSendingComment = false
                commentFieldFocused = false
            }
        }
    }
}
