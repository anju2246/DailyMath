import Foundation
import Combine

// MARK: - Login ViewModel

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var toast: Toast?

    // mirror the service state so views can bind directly
    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false

    private var authService: AuthService
    private var cancellables = Set<AnyCancellable>() 

    init(authService: AuthService) {
        self.authService = authService
        bind(to: authService)
    }

    /// Change the service instance (used when the view appears).
    func update(authService: AuthService) {
        guard self.authService !== authService else { return }
        self.authService = authService
        cancellables.removeAll()
        bind(to: authService)
    }

    private func bind(to service: AuthService) {
        service.$isLoading
            .receive(on: RunLoop.main)
            .assign(to: &$isLoading)

        service.$isAuthenticated
            .receive(on: RunLoop.main)
            .assign(to: &$isAuthenticated)

        service.$errorMessage
            .compactMap { $0 }
            .map { Toast(message: $0, style: .error) }
            .sink { [weak self] t in
                self?.toast = t
            }
            .store(in: &cancellables)
    }

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    /// Perform a login using the injected authService.
    @MainActor
    func login() async {
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
