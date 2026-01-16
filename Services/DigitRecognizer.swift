import PencilKit
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Reconocedor de Dígitos con Vision Framework
class DigitRecognizer {
    
    private let context = CIContext()
    
    // Reconocer desde PKDrawing (PencilKit)
    func recognize(drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        recognizeWithVision(image, completion: completion)
    }
    
    // Reconocer desde UIImage (Manual Drawing)
    func recognize(image: UIImage, completion: @escaping (String?) -> Void) {
        // Preprocesar imagen
        let processedImage = preprocessImage(image)
        recognizeWithVision(processedImage, completion: completion)
    }
    
    // MARK: - Preprocesamiento de Imagen
    private func preprocessImage(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // 1. Convertir a escala de grises
        let grayscaleFilter = CIFilter.colorControls()
        grayscaleFilter.inputImage = ciImage
        grayscaleFilter.saturation = 0
        grayscaleFilter.contrast = 2.0  // Alto contraste
        grayscaleFilter.brightness = 0.1
        
        guard let grayscaleOutput = grayscaleFilter.outputImage else { return image }
        
        // 2. Binarización (blanco y negro puro)
        let thresholdFilter = CIFilter(name: "CIColorThreshold")
        thresholdFilter?.setValue(grayscaleOutput, forKey: kCIInputImageKey)
        thresholdFilter?.setValue(0.5, forKey: "inputThreshold")
        
        let finalOutput = thresholdFilter?.outputImage ?? grayscaleOutput
        
        guard let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Reconocimiento con Vision
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
            
            // Buscar números en todos los resultados
            var allNumbers: [(String, Float)] = []
            
            for observation in observations {
                for candidate in observation.topCandidates(5) {
                    let numbers = candidate.string.filter { $0.isNumber }
                    if !numbers.isEmpty {
                        allNumbers.append((numbers, candidate.confidence))
                    }
                }
            }
            
            // Ordenar por confianza y tomar el mejor
            allNumbers.sort { $0.1 > $1.1 }
            let bestNumber = allNumbers.first?.0
            
            if let number = bestNumber {
                print("📝 Reconocido: \(number) (confianza: \(Int((allNumbers.first?.1 ?? 0) * 100))%)")
            } else {
                print("❌ No se reconoció ningún número")
            }
            
            DispatchQueue.main.async {
                completion(bestNumber)
            }
        }
        
        // Configuración optimizada para dígitos manuscritos
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        request.customWords = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                               "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                               "20", "21", "22", "23", "24", "25", "30", "40", "50", "60",
                               "70", "80", "90", "100"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ Error en Vision: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}