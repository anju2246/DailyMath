import PencilKit
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Reconocedor de Dígitos Optimizado (Ensemble + Heuristics)
class DigitRecognizer {
    
    private let context = CIContext()
    
    // Mapeo de confusiones comunes de Vision Framework (Letras a Números)
    private let specialMappings: [String: String] = [
        "O": "0", "o": "0", "()": "0", "D": "0", "U": "0", "Q": "0",
        "I": "1", "l": "1", "|": "1", "!": "1", "j": "1", "i": "1", "L": "1",
        "Z": "2", "z": "2",
        "S": "5", "s": "5", "$": "5",
        "G": "6", "b": "6",
        "T": "7", "t": "7", "Y": "7",
        "B": "8",
        "q": "9", "g": "9", "p": "9"
    ]
    
    // Reconocer desde PKDrawing (PencilKit)
    func recognize(drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        recognizeMultiPath(image, completion: completion)
    }
    
    // Reconocer desde UIImage (Manual Drawing)
    func recognize(image: UIImage, completion: @escaping (String?) -> Void) {
        recognizeMultiPath(image, completion: completion)
    }
    
    // MARK: - Procesamiento Multi-Camino (Triple Path)
    private func recognizeMultiPath(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Path 1: Imagen Original (Centrada/Normalizada)
        // Path 2: Imagen Binarizada (Alto Contraste)
        // Path 3: Imagen con Dilatación (Trazos más gruesos)
        
        let binarizedImage = preprocessBinarized(image)
        let dilatedImage = preprocessDilated(image)
        
        let dispatchGroup = DispatchGroup()
        var allCandidates: [(String, Float)] = []
        
        let paths = [image, binarizedImage, dilatedImage]
        
        for pathImage in paths {
            dispatchGroup.enter()
            performVisionRequest(on: pathImage) { candidates in
                if let candidates = candidates {
                    allCandidates.append(contentsOf: candidates)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let finalResult = self.selectBestResult(allCandidates)
            completion(finalResult)
        }
    }
    
    // MARK: - Preprocesamientos
    private func preprocessBinarized(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.contrast = 5.0
        filter.brightness = 0.0
        filter.saturation = 0.0
        
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func preprocessDilated(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Usar un filtro de morfología para dilatar (engrosar) el trazo
        let filter = CIFilter.morphologyMaximum()
        filter.inputImage = ciImage
        filter.radius = 1.5 // Engrosar ligeramente
        
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Vision Request
    private func performVisionRequest(on image: UIImage, completion: @escaping ([(String, Float)]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            var candidates: [(String, Float)] = []
            
            for observation in observations {
                // Capturamos hasta 10 candidatos por observación para aplicar mejor nuestras heurísticas
                for candidate in observation.topCandidates(10) {
                    candidates.append((candidate.string, candidate.confidence))
                }
            }
            completion(candidates)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // MARK: - Lógica de Selección y Heurística de Precisión Extrema
    private func selectBestResult(_ results: [(String, Float)]) -> String? {
        if results.isEmpty { return nil }
        
        var mappedResults: [(String, Float)] = []
        
        for (rawText, confidence) in results {
            let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { continue }
            
            // 1. Si ya es un número, añadirlo tal cual
            let numbersOnly = text.filter { $0.isNumber }
            if !numbersOnly.isEmpty {
                mappedResults.append((numbersOnly, confidence))
            }
            
            // 2. Aplicar mapeo heurístico a letras individuales o combinaciones
            // Ej: "O" -> "0", "S" -> "5"
            if let mapped = specialMappings[text] {
                // Le damos una confianza un poco menor al mapeo para que el número real gane si existe
                mappedResults.append((mapped, confidence * 0.9))
            }
            
            // 3. Caso especial de Vision: a veces reconoce "1" como "l" interno
            // Procesamos el texto letra por letra si no es puramente numérico
            if numbersOnly.count != text.count {
                var hybridString = ""
                for char in text {
                    if char.isNumber {
                        hybridString.append(char)
                    } else if let digit = specialMappings[String(char)] {
                        hybridString.append(digit)
                    }
                }
                
                if !hybridString.isEmpty && hybridString.count == text.count {
                    mappedResults.append((hybridString, confidence * 0.85))
                }
            }
        }
        
        // Ordenar por confianza
        let finalSorted = mappedResults.sorted { $0.1 > $1.1 }
        
        if let best = finalSorted.first {
            print("💎 Best Final: \(best.0) (Confidence: \(Int(best.1 * 100))%)")
            return best.0
        }
        
        return nil
    }
}