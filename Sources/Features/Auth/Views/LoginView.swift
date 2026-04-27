import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @StateObject private var viewModel: LoginViewModel
    @State private var showInvalidAlert = false

    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }

    var body: some View {
        NavigationStack(path: $navigation.authPath) {
            ZStack {
                Color.dmBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    Spacer(minLength: DMSpacing.lg)
                    DMBrandHeader(tagline: L10n.authTagline)
                    Spacer(minLength: DMSpacing.lg)
                    formCard
                    Spacer()
                    bottomCTA
                }
                .padding(.horizontal, DMSpacing.lg)

                if showInvalidAlert {
                    DMAlertCard(
                        title: "Inicio de Sesión Inválido",
                        message: "Verifica tus credenciales de entrada.",
                        primaryTitle: "Continuar",
                        onPrimary: { showInvalidAlert = false }
                    )
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView()
                        .environmentObject(appState)
                        .environmentObject(navigation)
                case .otp(let email):
                    OTPView(email: email)
                case .onboarding:
                    OnboardingView(onFinish: { navigation.popAuth() })
                }
            }
            .sheet(item: $navigation.authSheet) { sheet in
                switch sheet {
                case .forgotPassword:
                    ForgotPasswordView()
                        .environmentObject(appState)
                        .environmentObject(navigation)
                }
            }
        }
        .onAppear {
            navigation.resetAuth()
            viewModel.update(authService: appState.authService)
        }
        .onChange(of: viewModel.toast) { _, new in
            if new?.style == .error { showInvalidAlert = true }
        }
    }

    private var header: some View {
        HStack {
            Button(L10n.commonBack) { }
                .font(DMFont.callout())
                .foregroundStyle(Color.dmTextSecondary)
            Spacer()
        }
        .padding(.top, DMSpacing.md)
    }

    private var formCard: some View {
        DMFormCard {
            DMUnderlineField(
                placeholder: L10n.commonEmail,
                text: $viewModel.email,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                autocapitalization: .never,
                trailingIcon: viewModel.email.isEmpty ? nil : "xmark.circle.fill",
                onTrailingTap: { viewModel.email = "" }
            )
            DMUnderlineField(
                placeholder: L10n.commonPassword,
                text: $viewModel.password,
                isSecure: true,
                contentType: .password,
                trailingIcon: viewModel.password.isEmpty ? nil : "xmark.circle.fill",
                onTrailingTap: { viewModel.password = "" }
            )

            HStack {
                Spacer()
                Button(L10n.authForgotPassword) {
                    navigation.presentAuthSheet(.forgotPassword)
                }
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
            }

            Button {
                hideKeyboard()
                Task { await viewModel.login() }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white).primaryButton()
                } else {
                    Text(L10n.authSignIn).primaryButton()
                }
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: DMSpacing.sm) {
            Text("¿No tienes cuenta?")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
            Button {
                navigation.pushAuth(.register)
            } label: {
                Text(L10n.authCreateAccount).secondaryButton()
            }
        }
        .padding(.bottom, DMSpacing.md)
    }
}
