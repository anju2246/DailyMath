import SwiftUI
import Combine

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var emailSent = false
    
    private var authService: AuthService { appState.authService }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if emailSent {
                    // Success state
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.badge.shield.half.filled")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        
                        Text("¡Correo enviado!")
                            .font(.title2.bold())
                        
                        Text("Revisa tu bandeja de entrada en **\(email)** para restablecer tu contraseña.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button("Volver al login") {
                            dismiss()
                        }
                        .secondaryButton()
                    }
                    .padding()
                } else {
                    // Form
                    VStack(spacing: 16) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 48))
                            .foregroundStyle(.tint)
                        
                        Text("Recuperar Contraseña")
                            .font(.title2.bold())
                        
                        Text("Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        TextField("Tu email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                        
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        
                        Button {
                            Task {
                                try await authService.resetPassword(email: email)
                                emailSent = true
                            }
                        } label: {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .primaryButton()
                            } else {
                                Text("Enviar enlace")
                                    .primaryButton()
                            }
                        }
                        .disabled(!email.isValidEmail || authService.isLoading)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Recuperar contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
