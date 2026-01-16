import PencilKit
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Reconocedor de Dígitos Híbrido (MNIST + Vision)
class DigitRecognizer {
    
    private let context = CIContext()
    private let mnistClassifier = MNISTClassifier()
    
    // Umbral de confianza para aceptar resultado MNIST
    private let mnistConfidenceThreshold: Float = 0.7
    
    // Reconocer desde PKDrawing (PencilKit)
    func recognize(drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        recognizeHybrid(image: image, completion: completion)
    }
    
    // Reconocer desde UIImage (Manual Drawing)
    func recognize(image: UIImage, completion: @escaping (String?) -> Void) {
        recognizeHybrid(image: image, completion: completion)
    }
    
    // MARK: - Reconocimiento Híbrido
    private func recognizeHybrid(image: UIImage, completion: @escaping (String?) -> Void) {
        // Preprocesar imagen
        let processedImage = preprocessImage(image)
        
        // Intentar primero con MNIST si el modelo está cargado
        if mnistClassifier.isModelLoaded {
            mnistClassifier.classify(image: processedImage) { [weak self] digit, confidence in
                if let digit = digit, let confidence = confidence, 
                   confidence >= (self?.mnistConfidenceThreshold ?? 0.7) {
                    // MNIST dio resultado confiable
                    print("✅ MNIST: \(digit) (confianza: \(Int(confidence * 100))%)")
                    completion(String(digit))
                } else {
                    // Fallback a Vision
                    print("⚠️ MNIST baja confianza, usando Vision...")
                    self?.recognizeWithVision(processedImage, completion: completion)
                }
            }
        } else {
            // Solo Vision
            recognizeWithVision(processedImage, completion: completion)
        }
    }
    
    // MARK: - Preprocesamiento de Imagen
    private func preprocessImage(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // 1. Agregar padding alrededor del dibujo
        let paddedImage = addPadding(to: ciImage, padding: 40)
        
        // 2. Aumentar contraste
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = paddedImage
        contrastFilter.contrast = 1.5
        contrastFilter.brightness = 0.1
        
        guard let outputImage = contrastFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func addPadding(to image: CIImage, padding: CGFloat) -> CIImage {
        let newExtent = image.extent.insetBy(dx: -padding, dy: -padding)
        
        // Crear fondo blanco
        let whiteBackground = CIImage(color: CIColor.white)
            .cropped(to: newExtent)
        
        // Componer imagen sobre fondo blanco con offset
        let translatedImage = image.transformed(by: CGAffineTransform(translationX: padding, y: padding))
        
        return translatedImage.composited(over: whiteBackground)
    }
    
    // MARK: - Reconocimiento con Vision (Fallback)
    private func recognizeWithVision(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Obtener múltiples candidatos y elegir el mejor número
            var bestNumber: String? = nil
            var bestConfidence: Float = 0
            
            for observation in observations {
                for candidate in observation.topCandidates(3) {
                    let numbers = candidate.string.filter { $0.isNumber }
                    if !numbers.isEmpty && candidate.confidence > bestConfidence {
                        bestNumber = numbers
                        bestConfidence = candidate.confidence
                    }
                }
            }
            
            print("📝 Vision: \(bestNumber ?? "nil") (confianza: \(Int(bestConfidence * 100))%)")
            
            DispatchQueue.main.async {
                completion(bestNumber)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        request.customWords = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}