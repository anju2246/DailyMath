import Foundation

protocol DuelRepository {
    func createDuel(inviteCode: String?, category: AppConstants.Category?) async throws -> Duel
    func joinDuel(inviteCode: String) async throws -> Duel
    func fetchActiveDuels(for userId: UUID) async throws -> [Duel]
    func fetchTournamentLeaderboard(tournamentId: UUID) async throws -> [TournamentParticipant]
}
