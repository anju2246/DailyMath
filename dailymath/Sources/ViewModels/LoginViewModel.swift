import Foundation
import Combine

// MARK: - Login ViewModel

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var toast: Toast?

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func login(authService: AuthService) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty else {
            toast = Toast(message: "El email es obligatorio", style: .warning)
            return
        }
        guard trimmedEmail.isValidEmail else {
            toast = Toast(message: "Ingresa un email válido", style: .error)
            return
        }
        guard !password.isEmpty else {
            toast = Toast(message: "La contraseña es obligatoria", style: .warning)
            return
        }

        do {
            try await authService.signIn(email: trimmedEmail, password: password)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
