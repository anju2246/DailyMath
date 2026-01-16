import SwiftUI
import PencilKit
import UIKit

// MARK: - Manual Drawing View (Fallback sin PencilKit)
struct ManualDrawingView: View {
    @Binding var strokes: [[CGPoint]]
    @State private var currentStroke: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo blanco
                Color.white
                
                // Strokes guardados
                ForEach(0..<strokes.count, id: \.self) { index in
                    StrokePath(points: strokes[index])
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                }
                
                // Stroke actual
                StrokePath(points: currentStroke)
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        if !currentStroke.isEmpty {
                            strokes.append(currentStroke)
                            currentStroke = []
                        }
                    }
            )
        }
    }
}

// Path helper para dibujar puntos conectados
struct StrokePath: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
    }
}

// MARK: - Extensión para convertir dibujo a imagen para Vision
extension ManualDrawingView {
    static func renderToImage(strokes: [[CGPoint]], size: CGSize) -> UIImage {
        // Usar escala 2x para mejor calidad
        let scale: CGFloat = 2.0
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            // Fondo blanco
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Dibujar strokes con líneas más gruesas para mejor reconocimiento
            UIColor.black.setStroke()
            for stroke in strokes {
                guard stroke.count > 1 else { continue }
                let path = UIBezierPath()
                path.lineWidth = 12  // Más grueso para mejor reconocimiento
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.move(to: stroke[0])
                for i in 1..<stroke.count {
                    path.addLine(to: stroke[i])
                }
                path.stroke()
            }
        }
    }
    
    // Calcular bounding box del dibujo
    static func getBounds(strokes: [[CGPoint]]) -> CGRect {
        guard !strokes.isEmpty else { return .zero }
        
        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity
        
        for stroke in strokes {
            for point in stroke {
                minX = min(minX, point.x)
                minY = min(minY, point.y)
                maxX = max(maxX, point.x)
                maxY = max(maxY, point.y)
            }
        }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}