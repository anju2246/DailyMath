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

    func primaryButton(isDisabled: Bool = false) -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isDisabled ? Color.dmTextSecondary.opacity(0.3) : Color.dmSuccess)
            .cornerRadius(DMRadius.pill)
            .opacity(isDisabled ? 0.6 : 1.0)
    }

    func secondaryButton(isDisabled: Bool = false) -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(Color.dmSurface)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isDisabled ? Color.dmTextSecondary.opacity(0.3) : Color.dmOnDark)
            .cornerRadius(DMRadius.pill)
            .opacity(isDisabled ? 0.6 : 1.0)
    }

    func accentButton(isDisabled: Bool = false) -> some View {
        self
            .font(DMFont.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isDisabled ? Color.dmTextSecondary.opacity(0.3) : Color.dmPrimary)
            .cornerRadius(DMRadius.pill)
            .opacity(isDisabled ? 0.6 : 1.0)
    }
}

extension String {
    var isValidEmail: Bool {
        let regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return self.wholeMatch(of: regex) != nil
    }
}

// MARK: - Navigation Gesture Fix
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
