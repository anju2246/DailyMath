import Foundation
import Combine

@MainActor
final class LocalExerciseRepository: ObservableObject, ExerciseRepository {
    @Published private(set) var exercises: [Exercise] = []

    private let store = LocalStore<Exercise>(filename: "exercises")
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        seedIfNeeded()
        refresh()
    }

    // MARK: - ExerciseRepository

    func fetchExercises(category: AppConstants.Category?, searchText: String?) async throws -> [Exercise] {
        let verified = AppConstants.ExerciseStatus.verified.rawValue
        let needle = searchText?.lowercased().trimmingCharacters(in: .whitespaces) ?? ""
        return store.filter { ex in
            guard ex.status == verified else { return false }
            if let category = category, ex.category != category.rawValue { return false }
            if !needle.isEmpty,
               !ex.title.lowercased().contains(needle),
               !ex.statement.lowercased().contains(needle) {
                return false
            }
            return true
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    func createExercise(_ payload: CreateExerciseDTO) async throws {
        let now = Date()
        let author = authService.currentUser
        let exercise = Exercise(
            id: UUID(),
            authorId: payload.authorId,
            title: payload.title,
            category: payload.category,
            statement: payload.statement,
            solution: payload.solution,
            imageUrl: payload.imageUrl,
            status: AppConstants.ExerciseStatus.pending.rawValue,
            rejectionReason: nil,
            verifiedBy: nil,
            votesCount: 0,
            isPreloaded: false,
            createdAt: now,
            updatedAt: now,
            author: author
        )
        store.upsert(exercise)

        if let user = author, user.id == payload.authorId {
            authService.updateCurrentProfile { profile in
                profile.points += AppConstants.ReputationPoints.createExercise
            }
        }
        refresh()
    }

    func fetchPendingExercises() async throws -> [Exercise] {
        store.filter { $0.status == AppConstants.ExerciseStatus.pending.rawValue }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func moderateExercise(id: UUID, status: AppConstants.ExerciseStatus, rejectionReason: String?) async throws {
        guard var exercise = store.find(where: { $0.id == id }) else { return }
        exercise.status = status.rawValue
        exercise.rejectionReason = rejectionReason
        exercise.verifiedBy = authService.currentUser?.id
        exercise.updatedAt = Date()
        store.upsert(exercise)

        if status == .verified {
            authService.updateCurrentProfile { _ in }
            awardPointsToAuthor(exerciseId: id, points: AppConstants.ReputationPoints.exerciseVerified)
        }

        refresh()
    }

    // MARK: - Helpers

    func find(id: UUID) -> Exercise? {
        store.find(where: { $0.id == id })
    }

    func incrementVotes(exerciseId: UUID, delta: Int) {
        guard var exercise = store.find(where: { $0.id == exerciseId }) else { return }
        exercise.votesCount = max(0, exercise.votesCount + delta)
        exercise.updatedAt = Date()
        store.upsert(exercise)
        refresh()
    }

    private func refresh() {
        self.exercises = store.all().sorted { $0.createdAt > $1.createdAt }
    }

    private func awardPointsToAuthor(exerciseId: UUID, points: Int) {
        // Author may not be the current user; if it is, we update profile.
        guard let exercise = store.find(where: { $0.id == exerciseId }) else { return }
        if let user = authService.currentUser, user.id == exercise.authorId {
            authService.updateCurrentProfile { profile in
                profile.points += points
                profile.reputation += points
            }
        }
    }

    // MARK: - Seed

    private func seedIfNeeded() {
        guard store.isEmpty else { return }
        let now = Date()
        let seedAuthorId = UUID()
        let seeds: [Exercise] = [
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                     authorId: seedAuthorId, title: "Derivada de sen(x)",
                     category: AppConstants.Category.calculoDiferencial.rawValue,
                     statement: "¿Cuál es la derivada de sen(x)?",
                     solution: "cos(x)\n\nPor definición, d/dx [sen(x)] = cos(x).",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 42,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil),
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                     authorId: seedAuthorId, title: "Integral por partes",
                     category: AppConstants.Category.calculoIntegral.rawValue,
                     statement: "Calcula ∫ x·cos(x) dx",
                     solution: "Usando integración por partes con u=x, dv=cos(x)dx:\ndu=dx, v=sen(x)\n\n∫ x·cos(x) dx = x·sen(x) - ∫ sen(x) dx = x·sen(x) + cos(x) + C",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 31,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil),
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                     authorId: seedAuthorId, title: "Identidad trigonométrica",
                     category: AppConstants.Category.trigonometria.rawValue,
                     statement: "Demuestra que sen²(x) + cos²(x) = 1",
                     solution: "Sea un triángulo rectángulo con hipotenusa c y catetos a, b.\nsen(x) = a/c, cos(x) = b/c\n\nsen²(x) + cos²(x) = a²/c² + b²/c² = (a²+b²)/c²\n\nPor el teorema de Pitágoras, a² + b² = c², entonces:\n(a²+b²)/c² = c²/c² = 1 ∎",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 28,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil),
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                     authorId: seedAuthorId, title: "Ecuación lineal",
                     category: AppConstants.Category.algebraLineal.rawValue,
                     statement: "Resuelve el sistema 2x+3y=7, x-y=1",
                     solution: "De la segunda ecuación: x = y + 1\nSustituyendo en la primera: 2(y+1) + 3y = 7\n2y + 2 + 3y = 7 → 5y = 5 → y = 1\nEntonces x = 1 + 1 = 2\n\nSolución: (x, y) = (2, 1)",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 19,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil),
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                     authorId: seedAuthorId, title: "Probabilidad condicional",
                     category: AppConstants.Category.probabilidad.rawValue,
                     statement: "Si P(A)=0.4 y P(B|A)=0.5, halla P(A∩B)",
                     solution: "Por definición de probabilidad condicional:\nP(B|A) = P(A∩B) / P(A)\n\nDespejando: P(A∩B) = P(B|A) · P(A) = 0.5 · 0.4 = 0.2",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 15,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil),
            Exercise(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                     authorId: seedAuthorId, title: "EDO de primer orden",
                     category: AppConstants.Category.ecuacionesDiferenciales.rawValue,
                     statement: "Resuelve dy/dx = 2xy",
                     solution: "Separando variables: dy/y = 2x·dx\n\nIntegrando ambos lados:\nln|y| = x² + C₁\n\ny = e^(x² + C₁) = C·e^(x²)\n\nSolución general: y = C·e^(x²)",
                     imageUrl: nil,
                     status: AppConstants.ExerciseStatus.verified.rawValue,
                     rejectionReason: nil, verifiedBy: nil, votesCount: 12,
                     isPreloaded: true, createdAt: now, updatedAt: now, author: nil)
        ]
        seeds.forEach { store.upsert($0) }
    }
}
