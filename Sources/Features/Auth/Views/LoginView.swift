import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @StateObject private var viewModel: LoginViewModel
    @State private var showInvalidAlert = false
    @State private var alertMessage = ""

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
                        title: L10n.authSignIn,
                        message: alertMessage,
                        primaryTitle: L10n.commonBack,
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
            if let toast = new, (toast.style == .error || toast.style == .warning) && 
                !toast.message.contains("obligatorio") && !toast.message.contains("inválido") {
                alertMessage = toast.message
                showInvalidAlert = true
            }
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
            DMValidatedField(
                placeholder: L10n.commonEmail,
                text: $viewModel.email,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                autocapitalization: .never,
                trailingIcon: viewModel.email.isEmpty ? nil : "xmark.circle.fill",
                onTrailingTap: { viewModel.email = "" },
                error: viewModel.emailError
            )
            DMValidatedField(
                placeholder: L10n.commonPassword,
                text: $viewModel.password,
                isSecure: true,
                contentType: .password,
                trailingIcon: viewModel.password.isEmpty ? nil : "xmark.circle.fill",
                onTrailingTap: { viewModel.password = "" },
                error: viewModel.passwordError
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
                Task { await viewModel.login() }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white).primaryButton()
                } else {
                    Text(L10n.authSignIn).primaryButton(isDisabled: !viewModel.isFormValid)
                }
            }
            .disabled(viewModel.isLoading || !viewModel.isFormValid)

            // MARK: - Demo Access Panel
            VStack(spacing: DMSpacing.xxs) {
                Text("Acceso Rápido (Demo)")
                    .font(DMFont.caption2())
                    .foregroundStyle(Color.dmTextSecondary)
                    .textCase(.uppercase)

                HStack(spacing: DMSpacing.sm) {
                    demoButton(
                        title: "Estudiante",
                        icon: "person.circle",
                        color: .blue,
                        email: "estudiante@dailymath.com"
                    )

                    demoButton(
                        title: "Moderador",
                        icon: "shield.lefthalf.filled",
                        color: .orange,
                        email: "moderador@dailymath.com"
                    )
                }
            }
            .padding(.top, DMSpacing.sm)
        }
    }

    private func demoButton(title: String, icon: String, color: Color, email: String) -> some View {
        Button {
            viewModel.email = email
            viewModel.password = "password123"
            Task { await viewModel.login() }
        } label: {
            Label(title, systemImage: icon)
                .font(DMFont.caption())
                .padding(DMSpacing.xs)
                .background(color.opacity(0.1))
                .cornerRadius(DMRadius.sm)
                .foregroundStyle(color)
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
