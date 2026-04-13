import SwiftUI
import Combine

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    private var authService: any AuthRepository { appState.authService }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if viewModel.emailSent {
                    // Success state
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.badge.shield.half.filled")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        
                        Text(L10n.authForgotSuccessTitle)
                            .font(.title2.bold())
                        
                        Text(L10n.authForgotSuccessBody(viewModel.email))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Button(L10n.authForgotBackToLogin) {
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
                        
                        Text(L10n.authForgotHeading)
                            .font(.title2.bold())
                        
                        Text(L10n.authForgotDescription)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        TextField(L10n.authForgotEmailPlaceholder, text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 8)
                        
                        if let toast = viewModel.toast {
                            Text(toast.message)
                                .font(.caption)
                                .foregroundStyle(toast.style.color)
                        }
                        
                        Button {
                            Task {
                                await viewModel.resetPassword(authService: authService)
                            }
                        } label: {
                            if appState.isAuthLoading {
                                ProgressView()
                                    .tint(.white)
                                    .primaryButton()
                            } else {
                                Text(L10n.authForgotSendLink)
                                    .primaryButton()
                            }
                        }
                        .disabled(!viewModel.email.isValidEmail || appState.isAuthLoading)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle(L10n.authForgotTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.commonClose) {
                        dismiss()
                    }
                }
            }
        }
    }
}
