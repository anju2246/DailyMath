import SwiftUI
import PencilKit

// MARK: - Canvas Simplificado con PKDrawing Binding
struct SimpleCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.tool = PKInkingTool(.pen, color: .black, width: 20)
        canvas.drawingPolicy = .anyInput
        canvas.allowsFingerDrawing = true  // ← CLAVE!
        canvas.isOpaque = true
        canvas.backgroundColor = UIColor.white
        canvas.delegate = context.coordinator
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SimpleCanvasView
        
        init(_ parent: SimpleCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}