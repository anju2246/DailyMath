import Foundation

// MARK: - Modelo de Datos
struct GameStats: Codable {
    var totalProblems: Int = 0
    var correctAnswers: Int = 0
    var averageTime: Double = 0
    var currentLevel: Int = 1
    var problemsByType: [String: Int] = [:]
    var accuracyByType: [String: Double] = [:]
    
    var accuracy: Double {
        guard totalProblems > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalProblems)
    }
}

struct MathProblem {
    let num1: Int
    let num2: Int
    let operation: String
    let answer: Int
    let difficulty: Int
    
    var displayText: String {
        "\(num1) \(operation) \(num2) = ?"
    }
}