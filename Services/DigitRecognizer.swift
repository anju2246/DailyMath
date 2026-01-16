import PencilKit
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Reconocedor de Dígitos Optimizado (Multi-Path)
class DigitRecognizer {
    
    private let context = CIContext()
    
    // Reconocer desde PKDrawing (PencilKit)
    func recognize(drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        recognizeMultiPath(image, completion: completion)
    }
    
    // Reconocer desde UIImage (Manual Drawing)
    func recognize(image: UIImage, completion: @escaping (String?) -> Void) {
        // Enviar a procesamiento multi-camino
        recognizeMultiPath(image, completion: completion)
    }
    
    // MARK: - Procesamiento Multi-Camino
    private func recognizeMultiPath(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Path 1: Imagen Original (Antialiased)
        // Path 2: Imagen Binarizada (Alto Contraste)
        let binarizedImage = preprocessBinarized(image)
        
        let dispatchGroup = DispatchGroup()
        var results: [(String, Float)] = []
        
        // Ejecutar Path 1
        dispatchGroup.enter()
        performVisionRequest(on: image) { result in
            if let result = result { results.append(result) }
            dispatchGroup.leave()
        }
        
        // Ejecutar Path 2
        dispatchGroup.enter()
        performVisionRequest(on: binarizedImage) { result in
            if let result = result { results.append(result) }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Elegir el mejor resultado basado en confianza y lógica de números
            let finalResult = self.selectBestResult(results)
            completion(finalResult)
        }
    }
    
    // MARK: - Binarización
    private func preprocessBinarized(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.contrast = 3.0
        filter.brightness = 0.0
        filter.saturation = 0.0
        
        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Vision Request
    private func performVisionRequest(on image: UIImage, completion: @escaping ((String, Float)?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            var bestCandidate: (String, Float)? = nil
            
            for observation in observations {
                // Buscamos en los mejores 5 candidatos
                for candidate in observation.topCandidates(5) {
                    let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    let numbers = text.filter { $0.isNumber }
                    
                    // Si el candidato es puramente numérico, le damos prioridad
                    if !numbers.isEmpty {
                        let confidence = candidate.confidence
                        if bestCandidate == nil || confidence > (bestCandidate?.1 ?? 0) {
                            bestCandidate = (numbers, confidence)
                        }
                    }
                }
            }
            completion(bestCandidate)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // MARK: - Lógica de Selección y Heurística
    private func selectBestResult(_ results: [(String, Float)]) -> String? {
        if results.isEmpty { return nil }
        
        // Ordenar por confianza
        let sortedResults = results.sorted { $0.1 > $1.1 }
        
        // Tomar el de mayor confianza
        let bestText = sortedResults.first?.0
        
        // Heurística de corrección (Heurística de "Dígitos solitarios")
        if let text = bestText {
            // Si detectó 'l' o 'I' como números (a veces Vision lo hace internamente)
            // Aunque ya filtramos por isNumber, a veces '1' se confunde con 'l' antes de filtrar
            
            // Corrección específica para confusiones comunes de Vision con dígitos
            // Nota: Aquí el texto ya es solo números debido al filtro anterior
            
            // Si el resultado es vacío pero tenemos candidatos, re-intentar con mapeos
            if text.isEmpty && !sortedResults.isEmpty {
                // Esto no debería pasar con el filtro isNumber arriba
            }
        }
        
        print("🎯 Resultado Final: \(bestText ?? "nil") (Paths: \(results.count))")
        return bestText
    }
}