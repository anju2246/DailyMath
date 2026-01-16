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
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Fondo blanco
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Dibujar strokes
            UIColor.black.setStroke()
            for stroke in strokes {
                guard stroke.count > 1 else { continue }
                let path = UIBezierPath()
                path.lineWidth = 8
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
}