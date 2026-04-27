import Foundation
import Combine

// MARK: - Login ViewModel

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var toast: Toast?

    // mirror the service state so views can bind directly
    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false

    private var authService: any AuthRepository
    private var cancellables = Set<AnyCancellable>() 

    init(authService: any AuthRepository = AuthService()) {
        self.authService = authService
        bind(to: authService)
        setupValidation()
    }

    /// Change the service instance (used when the view appears).
    func update(authService: any AuthRepository) {
        guard (self.authService as AnyObject) !== (authService as AnyObject) else { return }
        self.authService = authService
        cancellables.removeAll()
        bind(to: authService)
    }

    private func bind(to service: any AuthRepository) {
        service.isLoadingPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isLoading)

        service.isAuthenticatedPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isAuthenticated)

        service.errorMessagePublisher
            .compactMap { $0 }
            .map { Toast(message: $0, style: .error) }
            .sink { [weak self] t in
                self?.toast = t
            }
            .store(in: &cancellables)
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

        $password
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { password -> String? in
                if password.isEmpty { return L10n.authValidationPasswordRequired }
                return nil
            }
            .assign(to: &$passwordError)
    }

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        emailError == nil &&
        !password.isEmpty &&
        passwordError == nil
    }

    /// Perform a login using the injected authService.
    @MainActor
    func login() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        var hasError = false

        if trimmedEmail.isEmpty {
            emailError = L10n.authValidationEmailRequired
            hasError = true
        } else if !trimmedEmail.isValidEmail {
            emailError = L10n.authValidationEmailInvalid
            hasError = true
        }

        if password.isEmpty {
            passwordError = L10n.authValidationPasswordRequired
            hasError = true
        }

        guard !hasError else { return }

        do {
            try await authService.signIn(email: trimmedEmail, password: password)
        } catch {
            toast = Toast(message: error.localizedDescription, style: .error)
        }
    }
}
