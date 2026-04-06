import SwiftUI
import Combine

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @StateObject private var viewModel: LoginViewModel

    init() {
        // `appState` is not yet available here;
        // we'll override the dependency in `.onAppear`.
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }

    var body: some View {
        NavigationStack(path: $navigation.authPath) {
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
                        TextField("Email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)

                        SecureField("Contraseña", text: $viewModel.password)
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)

                        if let toast = viewModel.toast {
                            Text(toast.message)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task {
                                await viewModel.login()
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .primaryButton()
                            } else {
                                Text("Iniciar Sesión")
                                    .primaryButton()
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)

                        Button("¿Olvidaste tu contraseña?") {
                            navigation.presentAuthSheet(.forgotPassword)
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
                        navigation.pushAuth(.register)
                    } label: {
                        Text("Crear cuenta")
                            .secondaryButton()
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .register:
                    RegisterView()
                        .environmentObject(appState)
                        .environmentObject(navigation)
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
            // Ensure the view model is bound to the shared auth repository instance.
            viewModel.update(authService: appState.authService)
        }
    }
}
