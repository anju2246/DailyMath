import Foundation
import Combine

@MainActor
final class LocalCommunityRepository: ObservableObject, CommunityRepository {
    @Published private(set) var commentsByExercise: [UUID: [Comment]] = [:]
    @Published private(set) var votesByCurrentUser: Set<UUID> = []

    private let voteStore = LocalStore<Vote>(filename: "votes")
    private let commentStore = LocalStore<Comment>(filename: "comments")
    private let badgeStore = LocalStore<UserBadge>(filename: "badges")
    private let notificationStore = LocalStore<AppNotification>(filename: "notifications")

    private let authService: AuthService
    private let exerciseRepo: LocalExerciseRepository
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService, exerciseRepo: LocalExerciseRepository) {
        self.authService = authService
        self.exerciseRepo = exerciseRepo
        rebuildCaches()

        // Refresh votes-by-current-user whenever the active user changes.
        authService.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.rebuildCaches() }
            .store(in: &cancellables)
    }

    // MARK: - CommunityRepository

    func fetchComments(for exerciseId: UUID) async throws -> [Comment] {
        commentStore.filter { $0.exerciseId == exerciseId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func createComment(exerciseId: UUID, content: String) async throws {
        guard let user = authService.currentUser else { return }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = Comment(
            id: UUID(),
            userId: user.id,
            exerciseId: exerciseId,
            content: trimmed,
            createdAt: Date(),
            user: user
        )
        commentStore.upsert(comment)
        rebuildCaches()
        authService.updateCurrentProfile { profile in
            profile.points += AppConstants.ReputationPoints.comment
        }
    }

    func vote(exerciseId: UUID) async throws {
        guard let user = authService.currentUser else { return }
        if let existing = voteStore.find(where: { $0.exerciseId == exerciseId && $0.userId == user.id }) {
            voteStore.delete(id: existing.id)
            exerciseRepo.incrementVotes(exerciseId: exerciseId, delta: -1)
        } else {
            let vote = Vote(id: UUID(), userId: user.id, exerciseId: exerciseId, createdAt: Date())
            voteStore.upsert(vote)
            exerciseRepo.incrementVotes(exerciseId: exerciseId, delta: 1)
            // Award point to the exercise author.
            if let exercise = exerciseRepo.find(id: exerciseId), exercise.authorId == user.id {
                authService.updateCurrentProfile { profile in
                    profile.points += AppConstants.ReputationPoints.voteReceived
                }
            }
        }
        rebuildCaches()
    }

    func fetchBadges(for userId: UUID) async throws -> [UserBadge] {
        badgeStore.filter { $0.userId == userId }
    }

    func fetchNotifications(for userId: UUID) async throws -> [AppNotification] {
        notificationStore.filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Helpers

    func hasVoted(exerciseId: UUID) -> Bool {
        votesByCurrentUser.contains(exerciseId)
    }

    func commentCount(exerciseId: UUID) -> Int {
        commentStore.filter { $0.exerciseId == exerciseId }.count
    }

    private func rebuildCaches() {
        var grouped: [UUID: [Comment]] = [:]
        for c in commentStore.all() {
            grouped[c.exerciseId, default: []].append(c)
        }
        for key in grouped.keys {
            grouped[key]?.sort { $0.createdAt < $1.createdAt }
        }
        self.commentsByExercise = grouped

        if let user = authService.currentUser {
            self.votesByCurrentUser = Set(voteStore.filter { $0.userId == user.id }.map { $0.exerciseId })
        } else {
            self.votesByCurrentUser = []
        }
    }
}
