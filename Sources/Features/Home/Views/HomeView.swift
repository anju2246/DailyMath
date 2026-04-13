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

                        Text(L10n.appName)
                            .font(.system(size: 44, weight: .heavy))

                        Text(L10n.homeLandingDescription)
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
                            title: L10n.homeFeatureSpacedReviewTitle,
                            description: L10n.homeFeatureSpacedReviewDescription
                        )
                        featureRow(
                            icon: "flame.fill",
                            color: .orange,
                            title: L10n.homeFeatureStreakTitle,
                            description: L10n.homeFeatureStreakDescription
                        )
                        featureRow(
                            icon: "person.2.fill",
                            color: .purple,
                            title: L10n.homeFeatureCommunityTitle,
                            description: L10n.homeFeatureCommunityDescription
                        )
                        featureRow(
                            icon: "bolt.fill",
                            color: .green,
                            title: L10n.homeFeatureAgilityTitle,
                            description: L10n.homeFeatureAgilityDescription
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)

                    // MARK: CTA Buttons
                    VStack(spacing: 12) {
                        Button {
                            showLogin = true
                        } label: {
                            Text(L10n.authSignIn)
                                .primaryButton()
                        }

                        Button {
                            showRegister = true
                        } label: {
                            Text(L10n.homeCreateAccountFree)
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
