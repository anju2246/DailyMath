import Foundation

protocol CommunityRepository {
    func fetchComments(for exerciseId: UUID) async throws -> [Comment]
    func createComment(exerciseId: UUID, content: String) async throws
    func vote(exerciseId: UUID) async throws
    func fetchBadges(for userId: UUID) async throws -> [UserBadge]
    func fetchNotifications(for userId: UUID) async throws -> [AppNotification]
}
