import Foundation
import Combine

// MARK: - Forgot Password ViewModel

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailSent = false
    @Published var toast: Toast?

    func resetPassword(authService: AuthService) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedEmail.isEmpty else {
            toast = Toast(message: "El email es obligatorio", style: .warning)
            return
        }
        guard trimmedEmail.isValidEmail else {
            toast = Toast(message: "Ingresa un email válido", style: .error)
            return
        }

        do {
            try await authService.resetPassword(email: trimmedEmail)
//            withAnimation {
//                emailSent = true
//            }
            toast = Toast(message: "Enlace enviado a \(trimmedEmail)", style: .success)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
