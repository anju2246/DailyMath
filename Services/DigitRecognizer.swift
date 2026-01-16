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
        "O": "0", "o": "0", "()": "0", "D": "0", "U": "0", "Q": "0", "@": "0", "C": "0",
        "I": "1", "l": "1", "|": "1", "!": "1", "j": "1", "i": "1", "L": "1",
        "Z": "2", "z": "2",
        "S": "5", "s": "5", "$": "5",
        "G": "6", "b": "6",
        "T": "7", "t": "7", "Y": "7",
        "B": "8", "&": "8", "8": "8", "E": "8", "X": "8",
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
            let finalResult = self.selectBestResult(allCandidates, originalImage: image)
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
        
        // Hint crucial para que Vision no ignore caracteres aislados como el 0
        request.customWords = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // MARK: - Lógica de Selección y Heurística de Precisión Extrema
    private func selectBestResult(_ results: [(String, Float)], originalImage: UIImage?) -> String? {
        if results.isEmpty {
            // Fallback para el cero si no se detectó nada pero hay dibujo
            if let img = originalImage, isLikelyZero(img) {
                print("🧠 Fallback Geométrico: Detectado forma de '0'")
                return "0"
            }
            return nil
        }
        
        var mappedResults: [(String, Float)] = []
        
        for (rawText, confidence) in results {
            let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { continue }
            
            // 1. Si ya es un número, añadirlo tal cual
            let numbersOnly = text.filter { $0.isNumber }
            if !numbersOnly.isEmpty {
                mappedResults.append((numbersOnly, confidence))
            }
            
            // 2. Aplicar mapeo heurístico
            if let mapped = specialMappings[text] {
                mappedResults.append((mapped, confidence * 0.9))
            }
            
            // 3. Caso especial Vision: "1" como "l"
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
            let bestValue = best.0
            
            // REFINAMIENTO GEOMÉTRICO para 6 vs 9
            if (bestValue == "6" || bestValue == "9"), let img = originalImage {
                let geometricResult = refineSixNine(img)
                print("🧠 Refinamiento Geométrico para \(bestValue): Resultó ser \(geometricResult)")
                return String(geometricResult)
            }
            
            // REFINAMIENTO para el 0 (si la confianza es baja y Vision dudó)
            if bestValue == "0" && best.1 < 0.6, let img = originalImage {
                if !isLikelyZero(img) {
                    // Si Vision cree que es 0 pero geométricamente no tiene forma de loop,
                    // tal vez sea otra cosa. Pero el 0 es el que más falla.
                }
            }
            
            print("💎 Best Final: \(bestValue) (Confidence: \(Int(best.1 * 100))%)")
            return bestValue
        }
        
        return nil
    }
    
    // MARK: - Análisis de Píxeles (Geometría)
    
    private func refineSixNine(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 6 }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var data = [UInt8](repeating: 0, count: bytesPerRow * height)
        let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var topWeight = 0
        var bottomWeight = 0
        let midY = height / 2
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * 4)
                let r = data[pixelIndex]
                if r < 128 { // Tinta negra
                    if y < midY {
                        bottomWeight += 1 // En CG y=0 es abajo
                    } else {
                        topWeight += 1
                    }
                }
            }
        }
        return topWeight > bottomWeight ? 9 : 6
    }
    
    private func isLikelyZero(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var data = [UInt8](repeating: 0, count: bytesPerRow * height)
        let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalDark = 0
        var centerDark = 0
        let centerX = width / 2
        let centerY = height / 2
        let margin = width / 5
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * 4)
                let r = data[pixelIndex]
                if r < 128 {
                    totalDark += 1
                    if abs(x - centerX) < margin && abs(y - centerY) < margin {
                        centerDark += 1
                    }
                }
            }
        }
        
        let density = Float(totalDark) / Float(width * height)
        let centerDensity = Float(centerDark) / Float(margin * margin * 4)
        
        // Un 0 tiene tinta en los bordes pero el centro está vacío
        return density > 0.01 && centerDensity < (density * 0.4)
    }
}