import Foundation

protocol UserProfileRepository {
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
    func deleteProfile(userId: UUID) async throws
}
