import SwiftUI
import Combine

// MARK: - Register View

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = RegisterViewModel()
    
    private var authService: any AuthRepository { appState.authService }
    
    private var isFormValid: Bool {
        viewModel.isFormValid
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
                        TextField("Tu nombre completo", text: $viewModel.displayName)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("correo@universidad.edu", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Universidad")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Ej: Universidad del Quindío", text: $viewModel.university)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contraseña")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Mínimo 6 caracteres", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirmar contraseña")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Repite tu contraseña", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if let toast = viewModel.toast {
                        Text(toast.message)
                            .font(.caption)
                            .foregroundStyle(toast.style.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        Task {
                            await viewModel.register(authService: authService)
                        }
                    } label: {
                        if appState.isAuthLoading {
                            ProgressView()
                                .tint(.white)
                                .primaryButton()
                        } else {
                            Text("Crear Cuenta")
                                .primaryButton()
                        }
                    }
                    .disabled(!isFormValid || appState.isAuthLoading)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
    }
}
