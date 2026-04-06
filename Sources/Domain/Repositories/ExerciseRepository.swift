import Foundation

protocol ExerciseRepository {
    func fetchExercises(category: AppConstants.Category?, searchText: String?) async throws -> [Exercise]
    func createExercise(_ payload: CreateExerciseDTO) async throws
    func fetchPendingExercises() async throws -> [Exercise]
    func moderateExercise(id: UUID, status: AppConstants.ExerciseStatus, rejectionReason: String?) async throws
}
