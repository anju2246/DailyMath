import SwiftUI

// MARK: - Home / Landing Screen

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Logo & Brand
                    VStack(spacing: 18) {
                        Image(systemName: "function")
                            .font(.system(size: 96, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 56)

                        Text("DailyMath")
                            .font(.system(size: 44, weight: .heavy))

                        Text("Practica matemáticas todos los días.\nMejora tu razonamiento con ejercicios\npersonalizados y tarjetas de estudio.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 48)

                    // MARK: Feature Highlights
                    VStack(spacing: 12) {
                        featureRow(
                            icon: "brain.head.profile",
                            color: .blue,
                            title: "Repaso Espaciado",
                            description: "Algoritmo SM-2 para memorización eficiente"
                        )
                        featureRow(
                            icon: "flame.fill",
                            color: .orange,
                            title: "Racha Diaria",
                            description: "Mantén el hábito de estudio cada día"
                        )
                        featureRow(
                            icon: "person.2.fill",
                            color: .purple,
                            title: "Comunidad",
                            description: "Compite y colabora con otros estudiantes"
                        )
                        featureRow(
                            icon: "bolt.fill",
                            color: .green,
                            title: "Agilidad Mental",
                            description: "Desafíos cronometrados para pensar rápido"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)

                    // MARK: CTA Buttons
                    VStack(spacing: 12) {
                        Button {
                            showLogin = true
                        } label: {
                            Text("Iniciar Sesión")
                                .primaryButton()
                        }

                        Button {
                            showRegister = true
                        } label: {
                            Text("Crear cuenta gratis")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.secondary.opacity(0.12))
                                .cornerRadius(14)
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
