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
                    
                    Text(L10n.authRegisterTitle)
                        .font(.title.bold())
                    
                    Text(L10n.authRegisterSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.authNameLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(L10n.authNamePlaceholder, text: $viewModel.displayName)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.commonEmail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(L10n.authEmailPlaceholder, text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.authUniversityLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField(L10n.authUniversityPlaceholder, text: $viewModel.university)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.commonPassword)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField(L10n.authPasswordPlaceholder, text: $viewModel.password)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.authConfirmPasswordLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField(L10n.authConfirmPasswordPlaceholder, text: $viewModel.confirmPassword)
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
                            Text(L10n.authRegisterTitle)
                                .primaryButton()
                        }
                    }
                    .disabled(!isFormValid || appState.isAuthLoading)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(L10n.authRegisterNavTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
