import Foundation
import Combine

// MARK: - Gestor de Estadísticas
class StatsManager: ObservableObject {
    @Published var stats = GameStats()
    private let key = "mathStats"
    
    init() {
        loadStats()
    }
    
    func loadStats() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(GameStats.self, from: data) {
            stats = decoded
        }
    }
    
    func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func recordAnswer(correct: Bool, time: Double, operation: String) {
        stats.totalProblems += 1
        if correct {
            stats.correctAnswers += 1
        }
        
        // Actualizar promedio de tiempo
        let total = stats.averageTime * Double(stats.totalProblems - 1) + time
        stats.averageTime = total / Double(stats.totalProblems)
        
        // Registrar por tipo
        stats.problemsByType[operation, default: 0] += 1
        let typeCorrect = stats.accuracyByType[operation, default: 0] * Double(stats.problemsByType[operation]! - 1)
        stats.accuracyByType[operation] = (typeCorrect + (correct ? 1 : 0)) / Double(stats.problemsByType[operation]!)
        
        // Ajustar nivel basado en precisión
        if stats.totalProblems % 10 == 0 {
            adjustLevel()
        }
        
        saveStats()
    }
    
    private func adjustLevel() {
        let recentAccuracy = stats.accuracy
        
        if recentAccuracy > 0.85 && stats.currentLevel < 10 {
            stats.currentLevel += 1
        } else if recentAccuracy < 0.60 && stats.currentLevel > 1 {
            stats.currentLevel -= 1
        }
    }
    
    func resetStats() {
        stats = GameStats()
        saveStats()
    }
}