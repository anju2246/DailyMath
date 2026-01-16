import UIKit

/// Gestiona el almacenamiento y carga de las plantillas de escritura del usuario.
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
    
    /// Guarda una imagen como plantilla para un dígito específico.
    func saveTemplate(image: UIImage, for digit: Int) {
        let fileURL = templatesDir.appendingPathComponent("template_\(digit).png")
        if let data = image.pngData() {
            try? data.write(to: fileURL)
            print("💾 Plantilla guardada para el dígito \(digit) en \(fileURL.lastPathComponent)")
        }
    }
    
    /// Carga la plantilla de un dígito si existe.
    func loadTemplate(for digit: Int) -> UIImage? {
        let fileURL = templatesDir.appendingPathComponent("template_\(digit).png")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Verifica si el usuario ya ha completado todas las plantillas (0-9).
    func hasAllTemplates() -> Bool {
        for i in 0...9 {
            if loadTemplate(for: i) == nil { return false }
        }
        return true
    }
    
    /// Borra todas las plantillas guardadas.
    func clearTemplates() {
        try? fileManager.removeItem(at: templatesDir)
        try? fileManager.createDirectory(at: templatesDir, withIntermediateDirectories: true)
    }
}
