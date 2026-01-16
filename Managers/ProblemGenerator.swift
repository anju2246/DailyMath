import Foundation

// MARK: - Generador de Problemas
class ProblemGenerator {
    func generate(level: Int) -> MathProblem {
        let operations = ["+", "-", "×", "÷"]
        let operation = operations.randomElement()!
        
        let maxNum = min(10 + (level * 10), 100)
        let minNum = max(1, level)
        
        switch operation {
        case "+":
            let n1 = Int.random(in: minNum...maxNum)
            let n2 = Int.random(in: minNum...maxNum)
            return MathProblem(num1: n1, num2: n2, operation: "+", answer: n1 + n2, difficulty: level)
            
        case "-":
            let n1 = Int.random(in: minNum...maxNum)
            let n2 = Int.random(in: minNum...n1)
            return MathProblem(num1: n1, num2: n2, operation: "-", answer: n1 - n2, difficulty: level)
            
        case "×":
            let n1 = Int.random(in: minNum...min(maxNum, 12))
            let n2 = Int.random(in: minNum...min(maxNum, 12))
            return MathProblem(num1: n1, num2: n2, operation: "×", answer: n1 * n2, difficulty: level)
            
        case "÷":
            let n2 = Int.random(in: minNum...min(maxNum, 12))
            let answer = Int.random(in: minNum...min(maxNum, 12))
            let n1 = n2 * answer
            return MathProblem(num1: n1, num2: n2, operation: "÷", answer: answer, difficulty: level)
            
        default:
            return generate(level: level)
        }
    }
}