import CoreML
import Vision
import UIKit

// MARK: - Clasificador MNIST con CoreML
class MNISTClassifier {
    
    private var model: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        // El modelo se compilará automáticamente cuando se agregue al proyecto
        guard let modelURL = Bundle.main.url(forResource: "MNIST", withExtension: "mlmodelc") else {
            print("⚠️ MNIST model not found in bundle")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: mlModel)
            print("✅ MNIST model loaded successfully")
        } catch {
            print("❌ Failed to load MNIST model: \(error)")
        }
    }
    
    // Clasificar imagen de dígito
    func classify(image: UIImage, completion: @escaping (Int?, Float?) -> Void) {
        guard let model = model else {
            completion(nil, nil)
            return
        }
        
        // Preprocesar imagen para MNIST (28x28, grayscale, inverted)
        guard let processedImage = preprocessForMNIST(image),
              let cgImage = processedImage.cgImage else {
            completion(nil, nil)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }
            
            let digit = Int(topResult.identifier)
            let confidence = topResult.confidence
            
            DispatchQueue.main.async {
                completion(digit, confidence)
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // Preprocesar imagen para formato MNIST (28x28, fondo negro, dígito blanco)
    private func preprocessForMNIST(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 28, height: 28)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Fondo negro
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: targetSize))
        
        // Dibujar imagen original escalada
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        
        guard let drawnImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Invertir colores (MNIST espera fondo negro con dígito blanco)
        guard let ciImage = CIImage(image: drawnImage) else { return nil }
        
        let filter = CIFilter(name: "CIColorInvert")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    var isModelLoaded: Bool {
        return model != nil
    }
}
