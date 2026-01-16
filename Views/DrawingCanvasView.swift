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
    
    // Renderizar solo el área del dibujo con padding
    static func renderToImage(strokes: [[CGPoint]], size: CGSize) -> UIImage {
        guard !strokes.isEmpty else {
            return createBlankImage(size: CGSize(width: 100, height: 100))
        }
        
        // Obtener bounds del dibujo
        let bounds = getBounds(strokes: strokes)
        guard bounds.width > 0 && bounds.height > 0 else {
            return createBlankImage(size: CGSize(width: 100, height: 100))
        }
        
        // Agregar padding y hacer cuadrado
        let padding: CGFloat = 30
        let maxDimension = max(bounds.width, bounds.height)
        let outputSize = CGSize(width: maxDimension + padding * 2, height: maxDimension + padding * 2)
        
        // Calcular offset para centrar
        let offsetX = padding + (maxDimension - bounds.width) / 2 - bounds.minX
        let offsetY = padding + (maxDimension - bounds.height) / 2 - bounds.minY
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        return renderer.image { context in
            // Fondo blanco
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: outputSize))
            
            // Dibujar strokes trasladados y centrados
            UIColor.black.setStroke()
            for stroke in strokes {
                guard stroke.count > 1 else { continue }
                let path = UIBezierPath()
                path.lineWidth = 15  // Líneas gruesas para mejor reconocimiento
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                
                let firstPoint = CGPoint(x: stroke[0].x + offsetX, y: stroke[0].y + offsetY)
                path.move(to: firstPoint)
                
                for i in 1..<stroke.count {
                    let point = CGPoint(x: stroke[i].x + offsetX, y: stroke[i].y + offsetY)
                    path.addLine(to: point)
                }
                path.stroke()
            }
        }
    }
    
    private static func createBlankImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
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