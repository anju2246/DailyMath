import Foundation

// MARK: - SM-2 Spaced Repetition Algorithm
// Reference: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method

struct SM2Algorithm {
    
    /// Result of applying the SM-2 algorithm after a review
    struct ReviewResult {
        let easinessFactor: Double
        let interval: Int           // Days until next review
        let repetitions: Int
        let nextReviewDate: Date
    }
    
    /// Apply SM-2 algorithm based on user's quality rating
    /// - Parameters:
    ///   - quality: User's rating (0-5). In our app: Difícil=0, Normal=3, Fácil=5
    ///   - repetitions: Number of consecutive correct responses
    ///   - easinessFactor: Current easiness factor (default 2.5)
    ///   - interval: Current interval in days
    /// - Returns: Updated SM-2 parameters
    static func calculate(
        quality: Int,
        repetitions: Int,
        easinessFactor: Double,
        interval: Int
    ) -> ReviewResult {
        var newEF = easinessFactor
        var newRepetitions = repetitions
        var newInterval = interval
        
        // Quality must be 0-5
        let q = max(0, min(5, quality))
        
        if q >= 3 {
            // Correct response
            switch newRepetitions {
            case 0:
                newInterval = 1
            case 1:
                newInterval = 6
            default:
                newInterval = Int(round(Double(interval) * easinessFactor))
            }
            newRepetitions += 1
        } else {
            // Incorrect response — reset
            newRepetitions = 0
            newInterval = 1
        }
        
        // Update easiness factor
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        let qDouble = Double(q)
        newEF = easinessFactor + (0.1 - (5.0 - qDouble) * (0.08 + (5.0 - qDouble) * 0.02))
        
        // EF must not go below 1.3
        newEF = max(1.3, newEF)
        
        // Calculate next review date
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: newInterval,
            to: Date()
        ) ?? Date()
        
        return ReviewResult(
            easinessFactor: newEF,
            interval: newInterval,
            repetitions: newRepetitions,
            nextReviewDate: nextDate
        )
    }
    
    /// Convert ReviewQuality enum to SM-2 quality score (0-5)
    static func qualityScore(from review: ReviewQuality) -> Int {
        return review.rawValue
    }
}
