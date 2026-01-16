import UIKit
import PencilKit

// MARK: - Protocolo para comunicación con SwiftUI
protocol CanvasViewControllerDelegate: AnyObject {
    func canvasDidRecognize(drawing: PKDrawing)
    func canvasWasCleared()
}

// MARK: - Controlador UIKit con PKCanvasView nativo
class CanvasViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CanvasViewControllerDelegate?
    
    private lazy var canvasView: PKCanvasView = {
        let canvas = PKCanvasView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .white
        canvas.isOpaque = true
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvas.isScrollEnabled = false
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        canvas.layer.cornerRadius = 20
        canvas.layer.masksToBounds = true
        canvas.layer.borderWidth = 3
        canvas.layer.borderColor = UIColor.systemBlue.cgColor
        return canvas
    }()
    
    // MARK: - Public Methods
    func getDrawing() -> PKDrawing {
        return canvasView.drawing
    }
    
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
        delegate?.canvasWasCleared()
    }
    
    func isCanvasEmpty() -> Bool {
        return canvasView.drawing.bounds.isEmpty
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
    }
    
    private func setupCanvas() {
        view.backgroundColor = .clear
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Ensure touch is enabled
        canvasView.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure the canvas becomes first responder for touch
        canvasView.becomeFirstResponder()
    }
}
