import SwiftUI

// MARK: - Agility View (Mental Math with Duolingo-style Keyboard)

struct AgilityView: View {
    @State private var currentLevel = 1
    @State private var score = 0
    @State private var userAnswer = ""
    @State private var currentProblem: AgilityProblem? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var problemsCount = 0
    @State private var correctCount = 0
    @State private var startTime = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(correctCount) / 10.0)
                        .animation(.spring(), value: correctCount)
                }
            }
            .frame(height: 10)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Stats row
            HStack {
                Label(L10n.agilityLevel(currentLevel), systemImage: "star.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.orange)
                
                Spacer()
                
                Text(L10n.agilityProgress(correctCount))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Spacer()
            
            // Problem display
            if let problem = currentProblem {
                Text(problem.displayText)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .padding()
            }
            
            // Answer display
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(showResult
                          ? (isCorrect ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                          : Color(.systemGray6)
                    )
                    .frame(height: 56)
                
                Text(userAnswer.isEmpty ? " " : userAnswer)
                    .font(.title.bold().monospacedDigit())
                    .foregroundStyle(
                        showResult
                        ? (isCorrect ? .green : .red)
                        : .primary
                    )
            }
            .padding(.horizontal, 40)
            .animation(.easeInOut(duration: 0.2), value: showResult)
            
            // Feedback
            if showResult {
                HStack(spacing: 8) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(isCorrect ? L10n.agilityCorrect : L10n.agilityAnswer(currentProblem?.answer ?? 0))
                }
                .font(.headline)
                .foregroundStyle(isCorrect ? .green : .red)
                .padding(.top, 12)
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // Continue button (when showing result)
            if showResult {
                Button {
                    nextProblem()
                } label: {
                    Text(L10n.commonContinueUppercase)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Numeric Keyboard
            NumericKeyboardView(
                text: $userAnswer,
                isDisabled: showResult
            ) {
                checkAnswer()
            }
            .padding(.bottom, 8)
        }
        .navigationTitle(L10n.agilityTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            nextProblem()
        }
        .animation(.spring(response: 0.3), value: showResult)
    }
    
    private func nextProblem() {
        showResult = false
        userAnswer = ""
        currentProblem = AgilityProblem.generate(level: currentLevel)
        startTime = Date()
    }
    
    private func checkAnswer() {
        guard let problem = currentProblem,
              let answer = Int(userAnswer) else { return }
        
        isCorrect = answer == problem.answer
        showResult = true
        problemsCount += 1
        
        if isCorrect {
            correctCount += 1
            score += 1
        }
        
        // Level up after 10 correct
        if correctCount >= 10 {
            currentLevel += 1
            correctCount = 0
        }
    }
}

// MARK: - Agility Problem Generator

struct AgilityProblem {
    let num1: Int
    let num2: Int
    let operation: String
    let answer: Int
    
    var displayText: String {
        "\(num1) \(operation) \(num2) = ?"
    }
    
    static func generate(level: Int) -> AgilityProblem {
        let operations = ["+", "-", "×", "÷"]
        let op = operations[Int.random(in: 0..<min(level + 1, operations.count))]
        
        let maxNum = min(10 + level * 5, 100)
        
        var num1: Int
        var num2: Int
        var answer: Int
        
        switch op {
        case "+":
            num1 = Int.random(in: 1...maxNum)
            num2 = Int.random(in: 1...maxNum)
            answer = num1 + num2
        case "-":
            num1 = Int.random(in: 1...maxNum)
            num2 = Int.random(in: 1...num1) // Ensure positive result
            answer = num1 - num2
        case "×":
            num1 = Int.random(in: 1...min(level + 3, 15))
            num2 = Int.random(in: 1...min(level + 3, 15))
            answer = num1 * num2
        case "÷":
            num2 = Int.random(in: 1...min(level + 3, 12))
            answer = Int.random(in: 1...min(level + 3, 12))
            num1 = num2 * answer // Ensure clean division
        default:
            num1 = 1; num2 = 1; answer = 2
        }
        
        return AgilityProblem(num1: num1, num2: num2, operation: op, answer: answer)
    }
}
