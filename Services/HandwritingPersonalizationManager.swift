import UIKit

/// Representa un punto normalizado (O.0 a 1.0) para almacenamiento eficiente.
struct NormalizedPoint: Codable {
    let x: Float
    let y: Float
}

/// Gestiona el almacenamiento y carga de las plantillas de escritura (trazo) del usuario.
class HandwritingPersonalizationManager {
    static let shared = HandwritingPersonalizationManager()
    
    private let fileManager = FileManager.default
    private let templatesDir: URL
    
    private init() {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        templatesDir = documents.appendingPathComponent("HandwritingTemplates")
        
        if !fileManager.fileExists(atPath: templatesDir.path) {
            try? fileManager.createDirectory(at: templatesDir, withIntermediateDirectories: true)
        }
    }
    
    /// Normaliza un trazo (CGPoint) a un espacio 1.0 x 1.0 para comparación consistente.
    func normalize(strokes: [[CGPoint]]) -> [NormalizedPoint] {
        let allPoints = strokes.flatMap { $0 }
        guard !allPoints.isEmpty else { return [] }
        
        let minX = allPoints.map { $0.x }.min() ?? 0
        let maxX = allPoints.map { $0.x }.max() ?? 1
        let minY = allPoints.map { $0.y }.min() ?? 0
        let maxY = allPoints.map { $0.y }.max() ?? 1
        
        let width = maxX - minX
        let height = maxY - minY
        let maxDim = max(width, height, 1.0)
        
        return allPoints.map { point in
            NormalizedPoint(
                x: Float((point.x - minX) / maxDim),
                y: Float((point.y - minY) / maxDim)
            )
        }
    }
    
    /// Guarda los puntos del trazo como plantilla para un dígito específico.
    func saveStrokeTemplate(_ points: [NormalizedPoint], for digit: Int) {
        let fileURL = templatesDir.appendingPathComponent("stroke_template_\(digit).json")
        if let data = try? JSONEncoder().encode(points) {
            try? data.write(to: fileURL)
            print("💾 Trazo guardado para el dígito \(digit)")
        }
    }
    
    /// Carga los puntos del trazo de un dígito si existe.
    func loadStrokeTemplate(for digit: Int) -> [NormalizedPoint]? {
        let fileURL = templatesDir.appendingPathComponent("stroke_template_\(digit).json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode([NormalizedPoint].self, from: data)
    }
    
    /// Verifica si el usuario ya ha completado todas las plantillas (0-9).
    func hasAllTemplates() -> Bool {
        for i in 0...9 {
            if loadStrokeTemplate(for: i) == nil { return false }
        }
        return true
    }
    
    /// Borra todas las plantillas guardadas.
    func clearTemplates() {
        try? fileManager.removeItem(at: templatesDir)
        try? fileManager.createDirectory(at: templatesDir, withIntermediateDirectories: true)
    }
}
