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
            toast = Toast(message: "El nombre es obligatorio", style: .warning)
            return
        }
        guard !trimmedEmail.isEmpty, trimmedEmail.isValidEmail else {
            toast = Toast(message: "Ingresa un email válido", style: .error)
            return
        }
        guard password.count >= 6 else {
            toast = Toast(message: "La contraseña debe tener al menos 6 caracteres", style: .warning)
            return
        }
        guard password == confirmPassword else {
            toast = Toast(message: "Las contraseñas no coinciden", style: .error)
            return
        }

        do {
            try await authService.signUp(
                email: trimmedEmail,
                password: password,
                username: trimmedEmail,
                displayName: trimmedName
            )
            toast = Toast(message: "¡Cuenta creada con éxito!", style: .success)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
