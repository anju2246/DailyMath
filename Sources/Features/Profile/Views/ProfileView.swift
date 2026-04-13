import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var showDeleteConfirmation = false

    private var user: UserProfile? { appState.currentUser }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar & Name
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Text(user?.displayName?.prefix(1).uppercased() ?? "?")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }

                    Text(user?.displayName ?? L10n.commonUser)
                        .font(.title2.bold())

                    if let university = user?.university, !university.isEmpty {
                        Label(university, systemImage: "building.columns")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Level badge
                    if let user = user {
                        HStack(spacing: 6) {
                            Image(systemName: user.userLevel.icon)
                            Text(user.userLevel.name)
                            Text(L10n.commonBullet)
                            Text(L10n.profilePoints(user.points))
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.tint)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.dmPrimary.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .padding(.top)

                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(title: L10n.profilePointsTitle, value: "\(user?.points ?? 0)", icon: "star.fill", color: .orange)
                    StatCard(title: L10n.profileStreakTitle, value: L10n.profileStreakDays(user?.studyStreak ?? 0), icon: "flame.fill", color: .red)
                    StatCard(title: L10n.profileLevelTitle, value: user?.userLevel.name ?? L10n.profileLevelFallback, icon: "trophy.fill", color: .yellow)
                }
                .padding(.horizontal)

                // Menu items
                VStack(spacing: 2) {
                    MenuRow(icon: "pencil", title: L10n.profileEdit, color: .blue) {
                        navigation.pushProfile(.editProfile)
                    }

                    MenuRow(icon: "medal", title: L10n.profileBadges, color: .orange) {
                        navigation.pushProfile(.badges)
                    }

                    MenuRow(icon: "chart.bar", title: L10n.profileStats, color: .green) {
                        navigation.pushProfile(.stats)
                    }

                    if appState.isModerator {
                        MenuRow(icon: "shield.checkered", title: L10n.profileModeratorPanel, color: .purple) {
                            navigation.pushProfile(.moderatorDashboard)
                        }
                    }
                }
                .cardStyle()
                .padding(.horizontal)

                // Danger zone
                VStack(spacing: 2) {
                    MenuRow(icon: "rectangle.portrait.and.arrow.right", title: L10n.profileSignOut, color: .secondary) {
                        Task { try? await appState.signOut() }
                    }

                    MenuRow(icon: "trash", title: L10n.profileDeleteAccount, color: .red) {
                        showDeleteConfirmation = true
                    }
                }
                .cardStyle()
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(L10n.profileTitle)
        .alert(L10n.profileDeleteAlertTitle, isPresented: $showDeleteConfirmation) {
            Button(L10n.commonCancel, role: .cancel) { }
            Button(L10n.commonDelete, role: .destructive) {
                Task { try? await appState.deleteAccount() }
            }
        } message: {
            Text(L10n.profileDeleteAlertMessage)
        }
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.headline.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
    }
}
