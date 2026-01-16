import SwiftUI

struct OnboardingView: View {
    @State private var currentDigit = 0
    @State private var strokes: [[CGPoint]] = []
    @Environment(\.dismiss) var dismiss
    
    var onCompletion: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Entrena a DailyMath")
                    .font(.largeTitle)
                    .bold()
                
                Text("Dibuja los números para que la app aprenda tu estilo personal.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Indicador de Progreso
            HStack(spacing: 8) {
                ForEach(0...9, id: \.self) { index in
                    Circle()
                        .fill(index == currentDigit ? Color.blue : (index < currentDigit ? Color.green : Color.gray.opacity(0.3)))
                        .frame(width: 10, height: 10)
                }
            }
            
            // Instrucción principal
            VStack(spacing: 5) {
                Text("Dibuja el número:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("\(currentDigit)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            // Canvas de dibujo (Personalizado para Onboarding)
            ManualDrawingView(strokes: $strokes)
                .frame(width: 280, height: 280)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 15)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                )
            
            Spacer()
            
            // Botones
            HStack(spacing: 20) {
                Button(action: { strokes = [] }) {
                    Text("Borrar")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                
                Button(action: saveAndNext) {
                    Text(currentDigit < 9 ? "Siguiente" : "Finalizar")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(strokes.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(strokes.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func saveAndNext() {
        // 1. Renderizar el dibujo a UIImage
        // Nota: Reutilizamos la lógica de renderizado que ya perfeccionamos en DrawingCanvasView
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 224, height: 224))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 224, height: 224))
            
            UIColor.black.setStroke()
            let strokeWidth: CGFloat = 16 // Grosor extra para las plantillas
            
            // Calcular bounds para centrar (simplificado para onboarding)
            for stroke in strokes {
                guard stroke.count > 1 else { continue }
                let path = UIBezierPath()
                path.lineWidth = strokeWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                
                // Centrado manual básico para las plantillas
                // (Mejoramos esto en la implementación final si es necesario)
                path.move(to: stroke[0])
                for i in 1..<stroke.count {
                    path.addLine(to: stroke[i])
                }
                path.stroke()
            }
        }
        
        // 2. Guardar plantilla
        HandwritingPersonalizationManager.shared.saveTemplate(image: image, for: currentDigit)
        
        // 3. Avanzar o Terminar
        if currentDigit < 9 {
            withAnimation {
                currentDigit += 1
                strokes = []
            }
        } else {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            onCompletion()
        }
    }
}

// Preview omitido para brevedad
