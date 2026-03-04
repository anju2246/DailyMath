import Foundation
import Combine
import SwiftUI

// MARK: - Utility Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isPastOrToday: Bool {
        self <= Date()
    }
    
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_CO")
        return formatter.string(from: self)
    }
}

extension Color {
    static let dmAccent = Color("Accent")
    static let dmBackground = Color("Background")
    static let dmSurface = Color("Surface")
    static let dmSuccess = Color.green
    static let dmError = Color.red
    static let dmWarning = Color.orange
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.dmPrimary)
            .cornerRadius(14)
    }
    
    func secondaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(Color.dmPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.dmPrimary.opacity(0.12))
            .cornerRadius(14)
    }
}

extension String {
    var isValidEmail: Bool {
        let regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return self.wholeMatch(of: regex) != nil
    }
}
