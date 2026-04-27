import Foundation
import Combine

@MainActor
final class LocalUserProfileRepository: ObservableObject, UserProfileRepository {
    @Published private(set) var allProfiles: [UserProfile] = []

    private let accountStore = LocalStore<LocalAccount>(filename: "accounts")
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService
        refresh()

        authService.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    // MARK: - UserProfileRepository

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        guard let account = accountStore.find(where: { $0.id == userId }) else {
            throw AuthService.AuthError.userNotFound
        }
        return account.profile
    }

    func updateProfile(_ profile: UserProfile) async throws {
        guard var account = accountStore.find(where: { $0.id == profile.id }) else { return }
        account.profile = profile
        accountStore.upsert(account)
        refresh()
    }

    func deleteProfile(userId: UUID) async throws {
        accountStore.delete(id: userId)
        refresh()
    }

    // MARK: - Leaderboard

    func topUsers(limit: Int = 10) -> [UserProfile] {
        allProfiles
            .sorted { $0.points > $1.points }
            .prefix(limit)
            .map { $0 }
    }

    private func refresh() {
        let stored = accountStore.all().map { $0.profile }
        // Make sure the live `currentUser` from AuthService is reflected even if the
        // account hasn't been re-saved yet (e.g. after points changes).
        if let current = authService.currentUser {
            var merged = stored.filter { $0.id != current.id }
            merged.append(current)
            self.allProfiles = merged
        } else {
            self.allProfiles = stored
        }
    }
}
