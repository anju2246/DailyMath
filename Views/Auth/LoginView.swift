import SwiftUI
import Combine

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    private var authService: AuthService { appState.authService }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo & Header
                    VStack(spacing: 12) {
                        Image(systemName: "function")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("DailyMath")
                            .font(.largeTitle.bold())
                        
                        Text("Tu plataforma de estudio matemático")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Contraseña", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)
                        
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await authService.signIn(email: email, password: password)
                                } catch {
                                    await MainActor.run {
                                        authService.errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        } label: {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .primaryButton()
                            } else {
                                Text("Iniciar Sesión")
                                    .primaryButton()
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        
                        Button("¿Olvidaste tu contraseña?") {
                            showForgotPassword = true
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.quaternary)
                        Text("o")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.quaternary)
                    }
                    .padding(.horizontal)
                    
                    // Register
                    Button {
                        showRegister = true
                    } label: {
                        Text("Crear cuenta")
                            .secondaryButton()
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
                    .environmentObject(appState)
            }
        }
    }
}
