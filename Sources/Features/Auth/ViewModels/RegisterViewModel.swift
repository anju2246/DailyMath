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
    @Published var displayNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var toast: Toast?

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }

    private func setupValidation() {
        $displayName
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { name -> String? in
                name.trimmingCharacters(in: .whitespaces).isEmpty ? L10n.authValidationNameRequired : nil
            }
            .assign(to: &$displayNameError)

        $email
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { email -> String? in
                let trimmed = email.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { return L10n.authValidationEmailInvalid }
                if !trimmed.isValidEmail { return L10n.authValidationEmailInvalid }
                return nil
            }
            .assign(to: &$emailError)

        $password
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { pass -> String? in
                pass.count < 6 ? L10n.authValidationPasswordLength : nil
            }
            .assign(to: &$passwordError)

        Publishers.CombineLatest($password, $confirmPassword)
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { pass, confirm -> String? in
                if confirm.isEmpty { return nil }
                return pass == confirm ? nil : L10n.authValidationPasswordMismatch
            }
            .assign(to: &$confirmPasswordError)
    }

    var isFormValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty && displayNameError == nil &&
        !email.isEmpty && emailError == nil &&
        password.count >= 6 && passwordError == nil &&
        password == confirmPassword && confirmPasswordError == nil
    }

    func register(authService: any AuthRepository) async {
        let trimmedName  = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        var hasError = false

        if trimmedName.isEmpty {
            displayNameError = L10n.authValidationNameRequired
            hasError = true
        }

        if trimmedEmail.isEmpty {
            emailError = L10n.authValidationEmailInvalid // reuse or specific required message
            hasError = true
        } else if !trimmedEmail.isValidEmail {
            emailError = L10n.authValidationEmailInvalid
            hasError = true
        }

        if password.count < 6 {
            passwordError = L10n.authValidationPasswordLength
            hasError = true
        }

        if password != confirmPassword {
            confirmPasswordError = L10n.authValidationPasswordMismatch
            hasError = true
        }

        guard !hasError else { return }

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
