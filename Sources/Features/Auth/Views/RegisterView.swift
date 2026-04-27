import SwiftUI
import Combine

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegisterViewModel()
    @State private var acceptTerms = false
    @State private var showSuccess = false
    @State private var showError = false

    private var authService: any AuthRepository { appState.authService }

    private var isFormValid: Bool {
        viewModel.isFormValid && acceptTerms
    }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer(minLength: DMSpacing.lg)
                DMBrandHeader(tagline: L10n.authTagline)
                Spacer(minLength: DMSpacing.lg)
                formCard
                Spacer()
                bottomBar
            }
            .padding(.horizontal, DMSpacing.lg)

            if showError {
                DMAlertCard(
                    title: "Registro fallido",
                    message: viewModel.toast?.message ?? "No pudimos crear tu cuenta. Intenta de nuevo.",
                    primaryTitle: "Continuar",
                    onPrimary: { showError = false }
                )
            }
            if showSuccess {
                DMAlertCard(
                    title: "¡Bienvenido!",
                    message: "Tu cuenta fue creada con éxito.",
                    primaryTitle: "Continuar",
                    onPrimary: {
                        showSuccess = false
                        navigation.pushAuth(.otp(email: viewModel.email))
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.toast) { _, new in
            if let toast = new, (toast.style == .error || toast.style == .warning) &&
                !toast.message.contains("obligatorio") && !toast.message.contains("inválido") &&
                !toast.message.contains("longitud") && !toast.message.contains("coinciden") {
                showError = true
            }
            if new?.style == .success { showSuccess = true }
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

    private var formCard: some View {
        DMFormCard {
            DMValidatedField(
                placeholder: L10n.authNamePlaceholder,
                text: $viewModel.displayName,
                contentType: .name,
                autocapitalization: .words,
                error: viewModel.displayNameError
            )
            DMValidatedField(
                placeholder: L10n.commonEmail,
                text: $viewModel.email,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                autocapitalization: .never,
                error: viewModel.emailError
            )
            DMValidatedField(
                placeholder: L10n.commonPassword,
                text: $viewModel.password,
                isSecure: true,
                contentType: .newPassword,
                error: viewModel.passwordError
            )
            DMValidatedField(
                placeholder: L10n.authConfirmPasswordPlaceholder,
                text: $viewModel.confirmPassword,
                isSecure: true,
                contentType: .newPassword,
                error: viewModel.confirmPasswordError
            )
        }
    }

    private var bottomBar: some View {
        VStack(spacing: DMSpacing.md) {
            Toggle(isOn: $acceptTerms) {
                Text("Acepto los términos y condiciones")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmTextSecondary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.dmSuccess))

            Button {
                Task { await viewModel.register(authService: authService) }
            } label: {
                if appState.isAuthLoading {
                    ProgressView().tint(.white).primaryButton()
                } else {
                    Text("Registrarme").primaryButton(isDisabled: !isFormValid)
                }
            }
            .disabled(appState.isAuthLoading || !isFormValid)

            HStack(spacing: 4) {
                Text("¿Ya tienes cuenta?")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmTextSecondary)
                Button("Iniciar sesión") { dismiss() }
                    .font(DMFont.calloutEmphasized())
                    .foregroundStyle(.primary)
            }
        }
        .padding(.bottom, DMSpacing.md)
    }
}
