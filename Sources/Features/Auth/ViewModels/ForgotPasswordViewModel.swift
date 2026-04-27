import Foundation
import Combine

// MARK: - Forgot Password ViewModel

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailError: String?
    @Published var emailSent = false
    @Published var toast: Toast?

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }

    private func setupValidation() {
        $email
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { email -> String? in
                let trimmed = email.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { return L10n.authValidationEmailRequired }
                if !trimmed.isValidEmail { return L10n.authValidationEmailInvalid }
                return nil
            }
            .assign(to: &$emailError)
    }

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && emailError == nil
    }

    func resetPassword(authService: any AuthRepository) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        if trimmedEmail.isEmpty {
            emailError = L10n.authValidationEmailRequired
            return
        } else if !trimmedEmail.isValidEmail {
            emailError = L10n.authValidationEmailInvalid
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
