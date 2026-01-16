import SwiftUI
import PencilKit

// MARK: - Vista del Canvas
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        
        // Enable drawing with finger
        canvasView.drawingPolicy = .anyInput
        
        // Explicitly enable user interaction
        canvasView.isUserInteractionEnabled = true
        
        // Visual settings
        canvasView.backgroundColor = UIColor.white
        canvasView.isOpaque = true
        
        // Set the drawing tool
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        
        // Disable scrolling to prevent gesture conflicts
        canvasView.isScrollEnabled = false
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 1.0
        canvasView.bouncesZoom = false
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Ensure drawing is always enabled
        uiView.isUserInteractionEnabled = true
        uiView.drawingPolicy = .anyInput
        
        // Ensure the tool is always set correctly
        if !(uiView.tool is PKInkingTool) {
            uiView.tool = PKInkingTool(.pen, color: .black, width: 15)
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Drawing changed
        }
    }
}