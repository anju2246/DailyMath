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
        formatter.locale = Locale.current
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}

extension Color {
    static let dmAccent = Color("Accent")
    static let dmBackground = Color("Background")
    static let dmSurface = Color("Surface")
    static let dmPrimary = Color("DMPrimary")
    static let dmSecondary = Color("DMSecondary")
    static let dmSuccess = Color("DMSuccess")
    static let dmError = Color("DMError")
    static let dmWarning = Color("DMWarning")
    static let dmOnDark = Color("DMOnDark")
    static let dmTextSecondary = Color("DMTextSecondary")
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(DMSpacing.md)
            .background(Color.dmSurface)
            .cornerRadius(DMRadius.lg)
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 2)
    }

    func primaryButton() -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.dmSuccess)
            .cornerRadius(DMRadius.pill)
    }

    func secondaryButton() -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(Color.dmSurface)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.dmOnDark)
            .cornerRadius(DMRadius.pill)
    }

    func accentButton() -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.dmPrimary)
            .cornerRadius(DMRadius.pill)
    }
}

extension String {
    var isValidEmail: Bool {
        let regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return self.wholeMatch(of: regex) != nil
    }
}
