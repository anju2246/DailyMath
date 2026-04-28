import SwiftUI

struct AgilityView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator
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
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { navigation.dismissHomeFullScreen() } label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundStyle(Color.dmTextSecondary)
                    }
                    Spacer()
                    Text("Agilidad mental")
                        .font(DMFont.headline())
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, DMSpacing.lg)
                .padding(.top, DMSpacing.md)

                progressBar
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.md)

                statsRow
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.xs)

                Spacer()

                if let problem = currentProblem {
                    Text(problem.displayText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.primary)
                }

                answerField
                    .padding(.horizontal, DMSpacing.xl)
                    .padding(.top, DMSpacing.lg)

                if showResult {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(isCorrect ? "¡Correcto!" : "Respuesta: \(currentProblem?.answer ?? 0)")
                    }
                    .font(DMFont.headline())
                    .foregroundStyle(isCorrect ? Color.dmSuccess : Color.dmError)
                    .padding(.top, DMSpacing.sm)
                }

                Spacer()

                NumericKeyboardView(text: $userAnswer, isDisabled: showResult) { checkAnswer() }
                    .padding(.horizontal, DMSpacing.lg)

                Button {
                    if showResult { nextProblem() } else { checkAnswer() }
                } label: {
                    Text(showResult ? "Continuar" : "Enviar").accentButton()
                }
                .disabled(!showResult && userAnswer.isEmpty)
                .padding(.horizontal, DMSpacing.lg)
                .padding(.top, DMSpacing.md)
                .padding(.bottom, DMSpacing.md)
            }
        }
        .navigationBarHidden(true)
        .onAppear { nextProblem() }
        .animation(.spring(response: 0.3), value: showResult)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.dmTextSecondary.opacity(0.2))
                Capsule()
                    .fill(Color.dmSuccess)
                    .frame(width: geo.size.width * CGFloat(correctCount) / 10.0)
                    .animation(.spring(), value: correctCount)
            }
        }
        .frame(height: 4)
    }

    private var statsRow: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundStyle(Color.dmWarning)
                Text("Nivel \(currentLevel)").font(DMFont.calloutEmphasized()).foregroundStyle(Color.dmWarning)
            }
            Spacer()
            Text("\(correctCount)/10").font(DMFont.callout()).foregroundStyle(Color.dmTextSecondary)
        }
    }

    private var answerField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DMRadius.pill)
                .fill(Color.dmSurface)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: DMRadius.pill)
                        .stroke(showResult ? (isCorrect ? Color.dmSuccess : Color.dmError) : .clear, lineWidth: 2)
                )
            Text(userAnswer.isEmpty ? " " : userAnswer)
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(showResult ? (isCorrect ? Color.dmSuccess : Color.dmError) : .primary)
        }
    }

    private func nextProblem() {
        showResult = false
        userAnswer = ""
        currentProblem = AgilityProblem.generate(level: currentLevel)
        startTime = Date()
    }

    private func checkAnswer() {
        guard let problem = currentProblem, let answer = Int(userAnswer) else { return }
        isCorrect = answer == problem.answer
        showResult = true
        problemsCount += 1
        if isCorrect {
            correctCount += 1
            score += 1
        }
        if correctCount >= 10 {
            currentLevel += 1
            correctCount = 0
        }
    }
}

struct AgilityProblem {
    let num1: Int
    let num2: Int
    let operation: String
    let answer: Int

    var displayText: String { "\(num1)\(operation)\(num2) = ?" }

    static func generate(level: Int) -> AgilityProblem {
        let operations = ["+", "-", "×", "÷"]
        let op = operations[Int.random(in: 0..<min(level + 1, operations.count))]
        let maxNum = min(10 + level * 5, 100)
        var num1: Int, num2: Int, answer: Int
        switch op {
        case "+":
            num1 = Int.random(in: 1...maxNum); num2 = Int.random(in: 1...maxNum); answer = num1 + num2
        case "-":
            num1 = Int.random(in: 1...maxNum); num2 = Int.random(in: 1...num1); answer = num1 - num2
        case "×":
            num1 = Int.random(in: 1...min(level + 3, 15)); num2 = Int.random(in: 1...min(level + 3, 15)); answer = num1 * num2
        case "÷":
            num2 = Int.random(in: 1...min(level + 3, 12)); answer = Int.random(in: 1...min(level + 3, 12)); num1 = num2 * answer
        default:
            num1 = 1; num2 = 1; answer = 2
        }
        return AgilityProblem(num1: num1, num2: num2, operation: op, answer: answer)
    }
}
