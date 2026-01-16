import SwiftUI
import PencilKit
import Vision

// MARK: - Vista Principal del Juego
struct GameView: View {
    @EnvironmentObject var statsManager: StatsManager
    @State private var canvasView = PKCanvasView()
    @State private var currentProblem: MathProblem?
    @State private var recognizedNumber: String = ""
    @State private var isRecognizing = false
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var startTime = Date()
    
    private let problemGenerator = ProblemGenerator()
    private let recognizer = DigitRecognizer()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header con estadísticas
            HStack {
                VStack(alignment: .leading) {
                    Text("Nivel \(statsManager.stats.currentLevel)")
                        .font(.headline)
                    Text("Precisión: \(Int(statsManager.stats.accuracy * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(statsManager.stats.correctAnswers)/\(statsManager.stats.totalProblems)")
                    .font(.title2)
                    .bold()
            }
            .padding()
            
            Spacer()
            
            // Problema actual
            if let problem = currentProblem {
                Text(problem.displayText)
                    .font(.system(size: 48, weight: .bold))
                    .padding()
            }
            
            // Área de dibujo
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 3)
                    .background(Color.white)
                    .frame(height: 250)
                
                DrawingCanvasView(canvasView: $canvasView)
                    .frame(height: 250)
                    .cornerRadius(20)
            }
            .padding(.horizontal)
            
            // Número reconocido
            if !recognizedNumber.isEmpty {
                Text("Tu respuesta: \(recognizedNumber)")
                    .font(.title)
                    .foregroundColor(showResult ? (isCorrect ? .green : .red) : .blue)
            }
            
            Spacer()
            
            // Botones
            HStack(spacing: 20) {
                Button(action: clearCanvas) {
                    Label("Borrar", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: recognizeAndCheck) {
                    if isRecognizing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Label("Verificar", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .disabled(isRecognizing)
            }
            .padding(.horizontal)
            
            if showResult {
                Button(action: nextProblem) {
                    Text("Siguiente")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            nextProblem()
        }
    }
    
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
        recognizedNumber = ""
        showResult = false
    }
    
    private func recognizeAndCheck() {
        guard !canvasView.drawing.bounds.isEmpty else { return }
        
        isRecognizing = true
        
        recognizer.recognize(drawing: canvasView.drawing) { result in
            DispatchQueue.main.async {
                isRecognizing = false
                
                if let number = result, let userAnswer = Int(number) {
                    recognizedNumber = number
                    checkAnswer(userAnswer)
                } else {
                    recognizedNumber = "No reconocido"
                }
            }
        }
    }
    
    private func checkAnswer(_ userAnswer: Int) {
        guard let problem = currentProblem else { return }
        
        let correct = userAnswer == problem.answer
        isCorrect = correct
        showResult = true
        
        let timeTaken = Date().timeIntervalSince(startTime)
        statsManager.recordAnswer(correct: correct, time: timeTaken, operation: problem.operation)
        
        // Feedback háptico
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(correct ? .success : .error)
    }
    
    private func nextProblem() {
        currentProblem = problemGenerator.generate(level: statsManager.stats.currentLevel)
        clearCanvas()
        showResult = false
        startTime = Date()
    }
}