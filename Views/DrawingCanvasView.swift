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
    
    // Renderizar solo el área del dibujo con padding y normalización
    static func renderToImage(strokes: [[CGPoint]], size: CGSize) -> UIImage {
        guard !strokes.isEmpty else {
            return createBlankImage(size: CGSize(width: 224, height: 224))
        }
        
        // Obtener bounds del dibujo
        let bounds = getBounds(strokes: strokes)
        guard bounds.width > 0 && bounds.height > 0 else {
            return createBlankImage(size: CGSize(width: 224, height: 224))
        }
        
        // Objetivo: Imagen cuadrada de al menos 224x224 (estándar para muchas redes neuronales)
        let minTargetSize: CGFloat = 224
        let padding: CGFloat = 25
        
        let maxDimension = max(bounds.width, bounds.height)
        let outputDimension = max(maxDimension + padding * 2, minTargetSize)
        let outputSize = CGSize(width: outputDimension, height: outputDimension)
        
        // Calcular offset para centrar el dibujo en la imagen cuadrada
        let offsetX = (outputDimension - bounds.width) / 2 - bounds.minX
        let offsetY = (outputDimension - bounds.height) / 2 - bounds.minY
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0 // Renderizar a retina para más detalle
        
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        return renderer.image { context in
            // Fondo blanco
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: outputSize))
            
            // Dibujar strokes centrados
            UIColor.black.setStroke()
            
            // Grosor de línea proporcional al tamaño del dibujo para consistencia
            let strokeWidth = max(8, outputDimension * 0.05)
            
            for stroke in strokes {
                guard stroke.count > 1 else { continue }
                let path = UIBezierPath()
                path.lineWidth = strokeWidth
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