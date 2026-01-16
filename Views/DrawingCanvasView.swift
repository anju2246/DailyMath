import SwiftUI
import PencilKit

// MARK: - SwiftUI Wrapper for UIKit Canvas Controller
struct CanvasView: UIViewControllerRepresentable {
    let onCanvasReady: (CanvasViewController) -> Void
    
    func makeUIViewController(context: Context) -> CanvasViewController {
        let controller = CanvasViewController()
        
        // Pass controller reference back to SwiftUI
        DispatchQueue.main.async {
            onCanvasReady(controller)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
        // Nothing to update
    }
}