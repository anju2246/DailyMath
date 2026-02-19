import SwiftUI

// MARK: - Register View

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var university = ""
    @State private var showPasswordMismatch = false
    
    private var authService: AuthService { appState.authService }
    
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        email.isValidEmail &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.tint)
                    
                    Text("Crear Cuenta")
                        .font(.title.bold())
                    
                    Text("Únete a la comunidad DailyMath")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Tu nombre completo", text: $displayName)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("correo@universidad.edu", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Universidad")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Ej: Universidad del Quindío", text: $university)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contraseña")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Mínimo 6 caracteres", text: $password)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirmar contraseña")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Repite tu contraseña", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if showPasswordMismatch {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        if password != confirmPassword {
                            showPasswordMismatch = true
                            return
                        }
                        showPasswordMismatch = false
                        Task {
                            await authService.signUp(
                                email: email,
                                password: password,
                                displayName: displayName,
                                university: university.isEmpty ? nil : university
                            )
                        }
                    } label: {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                                .primaryButton()
                        } else {
                            Text("Crear Cuenta")
                                .primaryButton()
                        }
                    }
                    .disabled(!isFormValid || authService.isLoading)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
    }
}
