import Foundation
import Combine

// MARK: - Register ViewModel

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var university = ""
    @Published var toast: Toast?

    var isFormValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.isValidEmail &&
        password.count >= 6 &&
        password == confirmPassword
    }

    func register(authService: any AuthRepository) async {
        let trimmedName  = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            toast = Toast(message: L10n.authValidationNameRequired, style: .warning)
            return
        }
        guard !trimmedEmail.isEmpty, trimmedEmail.isValidEmail else {
            toast = Toast(message: L10n.authValidationEmailInvalid, style: .error)
            return
        }
        guard password.count >= 6 else {
            toast = Toast(message: L10n.authValidationPasswordLength, style: .warning)
            return
        }
        guard password == confirmPassword else {
            toast = Toast(message: L10n.authValidationPasswordMismatch, style: .error)
            return
        }

        do {
            try await authService.signUp(
                email: trimmedEmail,
                password: password,
                username: trimmedEmail,
                displayName: trimmedName
            )
            toast = Toast(message: L10n.authRegisterSuccess, style: .success)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
