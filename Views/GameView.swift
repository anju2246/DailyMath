import SwiftUI
import PencilKit
import Vision
import Combine

// MARK: - Vista Principal del Juego
struct GameView: View {
    @EnvironmentObject var statsManager: StatsManager
    @State private var strokes: [[CGPoint]] = []  // Para ManualDrawingView
    @State private var currentProblem: MathProblem?
    @State private var recognizedNumber: String = ""
    @State private var isRecognizing = false
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var startTime = Date()
    
    // Timer para auto-reconocimiento
    @State private var timerSubscription: AnyCancellable?
    private let autoRecognizeDelay: TimeInterval = 0.8
    
    private let problemGenerator = ProblemGenerator()
    private let recognizer = DigitRecognizer()
    private let canvasSize = CGSize(width: 350, height: 250)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
                .padding(.top)
                
                // Problema actual e Icono de Feedback
                ZStack {
                    if let problem = currentProblem {
                        Text(problem.displayText)
                            .font(.system(size: 48, weight: .bold))
                            .padding()
                            .blur(radius: showResult ? 3 : 0)
                    }
                    
                    if showResult {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(isCorrect ? .green : .red)
                            .background(Circle().fill(Color.white).shadow(radius: 10))
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                    }
                }
                .frame(height: 120)
                
                // Área de dibujo manual
                ManualDrawingView(strokes: $strokes)
                    .frame(height: 220) // Reducido un poco para mejor ajuste
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(showResult ? (isCorrect ? Color.green : Color.red) : Color.blue, lineWidth: 3)
                    )
                    .padding(.horizontal)
                    .onChange(of: strokes) { oldValue, newValue in
                        resetAutoRecognizeTimer()
                    }
                
                // Número reconocido
                VStack {
                    if !recognizedNumber.isEmpty {
                        Text("Tu respuesta: \(recognizedNumber)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(showResult ? (isCorrect ? .green : .red) : .blue)
                    }
                    
                    if isRecognizing {
                        Text("Reconociendo...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 50)
                
                // Botones
                HStack(spacing: 20) {
                    Button(action: clearCanvas) {
                        Label("Borrar", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: recognizeAndCheck) {
                        Label("Verificar", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .disabled(isRecognizing || strokes.isEmpty || showResult)
                }
                .padding(.horizontal)
                .opacity(showResult ? 0.3 : 1.0)
                
                if showResult {
                    Button(action: nextProblem) {
                        HStack {
                            Text(isCorrect ? "¡Excelente! Siguiente" : "Siguiente")
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Espacio extra para asegurar que nada quede bajo el TabBar
                Spacer().frame(height: 50)
            }
            .padding()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showResult)
        .onAppear {
            nextProblem()
        }
    }
    
    private func resetAutoRecognizeTimer() {
        // Cancelar timer anterior
        timerSubscription?.cancel()
        
        // No auto-reconocer si ya se mostró el resultado o si no hay trazos
        guard !showResult && !strokes.isEmpty else { return }
        
        // Iniciar nuevo timer
        timerSubscription = Just(())
            .delay(for: .seconds(autoRecognizeDelay), scheduler: RunLoop.main)
            .sink { _ in
                recognizeAndCheck()
            }
    }
    
    private func clearCanvas() {
        timerSubscription?.cancel()
        strokes = []
        recognizedNumber = ""
        showResult = false
    }
    
    private func recognizeAndCheck() {
        guard !strokes.isEmpty && !showResult else { return }
        
        // Evitar múltiples reconocimientos simultáneos
        timerSubscription?.cancel()
        isRecognizing = true
        
        // Renderizar dibujo a imagen (ahora con normalización y padding en DrawingCanvasView)
        let image = ManualDrawingView.renderToImage(strokes: strokes, size: canvasSize)
        
        recognizer.recognize(image: image) { result in
            DispatchQueue.main.async {
                isRecognizing = false
                
                if let number = result, let userAnswer = Int(number) {
                    recognizedNumber = number
                    checkAnswer(userAnswer)
                } else {
                    // Si falló el auto-reconocimiento, simplemente esperamos o avisamos
                    // No queremos que sea intrusivo si fue automático
                    if recognizedNumber.isEmpty {
                        recognizedNumber = "???"
                    }
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