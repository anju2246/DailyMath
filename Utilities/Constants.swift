import Foundation

// MARK: - App Constants

enum AppConstants {
    static let appName = "DailyMath"
    
    // Categorías de ejercicios
    enum Category: String, CaseIterable, Codable {
        case trigonometria = "trigonometria"
        case calculoDiferencial = "calculo_diferencial"
        case calculoIntegral = "calculo_integral"
        case ecuacionesDiferenciales = "ecuaciones_diferenciales"
        case algebraLineal = "algebra_lineal"
        case probabilidad = "probabilidad"
        
        var displayName: String {
            switch self {
            case .trigonometria: return "Trigonometría"
            case .calculoDiferencial: return "Cálculo Diferencial"
            case .calculoIntegral: return "Cálculo Integral"
            case .ecuacionesDiferenciales: return "Ecuaciones Diferenciales"
            case .algebraLineal: return "Álgebra Lineal"
            case .probabilidad: return "Probabilidad"
            }
        }
        
        var icon: String {
            switch self {
            case .trigonometria: return "triangle"
            case .calculoDiferencial: return "function"
            case .calculoIntegral: return "sum"
            case .ecuacionesDiferenciales: return "waveform.path"
            case .algebraLineal: return "square.grid.3x3"
            case .probabilidad: return "dice"
            }
        }
        
        var color: String {
            switch self {
            case .trigonometria: return "CategoryTrig"
            case .calculoDiferencial: return "CategoryCalcDiff"
            case .calculoIntegral: return "CategoryCalcInt"
            case .ecuacionesDiferenciales: return "CategoryEcuDiff"
            case .algebraLineal: return "CategoryAlgLin"
            case .probabilidad: return "CategoryProb"
            }
        }
    }
    
    // Estados de ejercicio
    enum ExerciseStatus: String, Codable {
        case pending = "pending"
        case verified = "verified"
        case rejected = "rejected"
        case archived = "archived"
        
        var displayName: String {
            switch self {
            case .pending: return "Pendiente"
            case .verified: return "Verificado"
            case .rejected: return "Rechazado"
            case .archived: return "Archivado"
            }
        }
    }
    
    // Sistema de reputación
    enum ReputationPoints {
        static let createExercise = 5
        static let exerciseVerified = 10
        static let comment = 2
        static let voteReceived = 1
        static let dailyReviewSession = 3
    }
    
    // Niveles de usuario
    enum UserLevel: Int, CaseIterable {
        case novato = 1
        case estudiante = 2
        case tutor = 3
        case maestro = 4
        
        var name: String {
            switch self {
            case .novato: return "Novato"
            case .estudiante: return "Estudiante"
            case .tutor: return "Tutor"
            case .maestro: return "Maestro"
            }
        }
        
        var minPoints: Int {
            switch self {
            case .novato: return 0
            case .estudiante: return 51
            case .tutor: return 201
            case .maestro: return 501
            }
        }
        
        var icon: String {
            switch self {
            case .novato: return "leaf"
            case .estudiante: return "book"
            case .tutor: return "graduationcap"
            case .maestro: return "star.circle.fill"
            }
        }
        
        static func level(for points: Int) -> UserLevel {
            if points >= 501 { return .maestro }
            if points >= 201 { return .tutor }
            if points >= 51 { return .estudiante }
            return .novato
        }
    }
    
    // Badges
    enum BadgeKey: String, CaseIterable {
        case firstFlashcard = "first_flashcard"
        case tenVerified = "ten_verified"
        case sevenDayStreak = "seven_day_streak"
        case hundredReviews = "hundred_reviews"
        case topVotedMonth = "top_voted_month"
        
        var displayName: String {
            switch self {
            case .firstFlashcard: return "Primera Flashcard"
            case .tenVerified: return "10 Ejercicios Verificados"
            case .sevenDayStreak: return "Racha de 7 Días"
            case .hundredReviews: return "100 Repasos"
            case .topVotedMonth: return "Más Votado del Mes"
            }
        }
        
        var icon: String {
            switch self {
            case .firstFlashcard: return "sparkles"
            case .tenVerified: return "checkmark.seal.fill"
            case .sevenDayStreak: return "flame.fill"
            case .hundredReviews: return "brain.head.profile"
            case .topVotedMonth: return "trophy.fill"
            }
        }
    }
    
    // Duelos
    enum DuelStatus: String, Codable {
        case waiting = "waiting"
        case active = "active"
        case finished = "finished"
        case cancelled = "cancelled"
    }
}
