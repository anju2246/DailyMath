import Foundation
import Combine

// MARK: - Forgot Password ViewModel

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailSent = false
    @Published var toast: Toast?

    func resetPassword(authService: any AuthRepository) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty else {
            toast = Toast(message: L10n.authValidationEmailRequired, style: .warning)
            return
        }
        guard trimmedEmail.isValidEmail else {
            toast = Toast(message: L10n.authValidationEmailInvalid, style: .error)
            return
        }

        do {
            try await authService.resetPassword(email: trimmedEmail)
            emailSent = true
            toast = Toast(message: L10n.authResetSentTo(trimmedEmail), style: .success)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
