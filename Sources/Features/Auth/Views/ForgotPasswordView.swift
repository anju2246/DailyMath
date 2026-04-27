import SwiftUI
import Combine

struct ForgotPasswordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @State private var showLinkSentAlert = false

    private var authService: any AuthRepository { appState.authService }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer(minLength: DMSpacing.xl)
                VStack(spacing: DMSpacing.sm) {
                    Text("Confirma tu correo\nelectrónico")
                        .font(DMFont.title())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    Text("Te enviaremos un link para que\nrecuperes tu cuenta")
                        .font(DMFont.callout())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.dmTextSecondary)
                }
                Spacer(minLength: DMSpacing.lg)
                DMFormCard {
                    DMValidatedField(
                        placeholder: L10n.commonEmail,
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        contentType: .emailAddress,
                        autocapitalization: .never,
                        error: viewModel.emailError
                    )
                    Button {
                        Task {
                            await viewModel.resetPassword(authService: authService)
                            if viewModel.emailSent { showLinkSentAlert = true }
                        }
                    } label: {
                        if appState.isAuthLoading {
                            ProgressView().tint(.white).primaryButton()
                        } else {
                            Text(L10n.authForgotSendLink).primaryButton(isDisabled: !viewModel.isFormValid)
                        }
                    }
                    .disabled(!viewModel.isFormValid || appState.isAuthLoading)
                }
                Spacer()
            }
            .padding(.horizontal, DMSpacing.lg)

            if showLinkSentAlert {
                DMAlertCard(
                    title: "Te enviamos un link para restaurar tu contraseña",
                    message: "Si tu cuenta existe, recibirás un email para recuperar tu contraseña.",
                    primaryTitle: "Continuar",
                    onPrimary: {
                        showLinkSentAlert = false
                        dismiss()
                    }
                )
            }
        }
    }

    private var header: some View {
        HStack {
            Button(L10n.commonBack) { dismiss() }
                .font(DMFont.callout())
                .foregroundStyle(Color.dmTextSecondary)
            Spacer()
        }
        .padding(.top, DMSpacing.md)
    }
}
