import PencilKit
import Vision

// MARK: - Reconocedor de Dígitos
class DigitRecognizer {
    func recognize(drawing: PKDrawing, completion: @escaping (String?) -> Void) {
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  let topCandidate = observations.first?.topCandidates(1).first else {
                completion(nil)
                return
            }
            
            // Filtrar solo números
            let text = topCandidate.string.filter { $0.isNumber }
            completion(text.isEmpty ? nil : text)
        }
        
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}