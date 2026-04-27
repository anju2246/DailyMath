import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirm = false
    @State private var showSettings = false

    private var user: UserProfile? { appState.currentUser }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: DMSpacing.md) {
                    topBar
                    avatarBlock
                    statsGrid
                    publicationsSection
                    menuCard
                    dangerCard
                }
                .padding(.horizontal, DMSpacing.lg)
                .padding(.bottom, DMSpacing.xxl)
            }
            if showLogoutConfirm {
                DMAlertCard(
                    title: "Cerrar sesión",
                    message: "¿Seguro que quieres cerrar tu sesión?",
                    primaryTitle: "Confirmar",
                    onPrimary: {
                        showLogoutConfirm = false
                        Task { try? await appState.signOut() }
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .alert(L10n.profileDeleteAlertTitle, isPresented: $showDeleteConfirmation) {
            Button(L10n.commonCancel, role: .cancel) { }
            Button(L10n.commonDelete, role: .destructive) {
                Task { try? await appState.deleteAccount() }
            }
        } message: {
            Text(L10n.profileDeleteAlertMessage)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack { SettingsView() }
                .environmentObject(appState)
        }
    }

    private var topBar: some View {
        HStack {
            Button { showLogoutConfirm = true } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(Color.dmOnDark)
            }
            Spacer()
            Text("Perfil").font(DMFont.headline())
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(Color.dmOnDark)
            }
        }
        .padding(.top, DMSpacing.sm)
    }

    private var avatarBlock: some View {
        VStack(spacing: DMSpacing.xs) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.dmPrimary, Color.dmSuccess],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)
                Text(user?.displayName?.prefix(1).uppercased() ?? "?")
                    .font(DMFont.title())
                    .foregroundStyle(.white)
            }
            HStack(spacing: 4) {
                Text(user?.displayName ?? L10n.commonUser)
                    .font(DMFont.title3())
                Image(systemName: "pencil")
                    .font(.footnote)
                    .foregroundStyle(Color.dmTextSecondary)
                    .onTapGesture { navigation.pushProfile(.editProfile) }
            }
            if let uni = user?.university, !uni.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns")
                    Text(uni)
                }
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
            }
        }
        .padding(.top, DMSpacing.sm)
    }

    private var statsGrid: some View {
        HStack(spacing: DMSpacing.sm) {
            profileStat(icon: "star.fill", tint: Color.dmWarning, value: "\(user?.points ?? 0)", label: "Puntos")
            profileStat(icon: "flame.fill", tint: Color.dmError, value: "\(user?.studyStreak ?? 0) días", label: "Racha")
            profileStat(icon: "trophy.fill", tint: Color.dmSuccess, value: user?.userLevel.name ?? "Novato", label: "Nivel")
        }
    }

    private func profileStat(icon: String, tint: Color, value: String, label: String) -> some View {
        VStack(spacing: DMSpacing.xs) {
            Image(systemName: icon).foregroundStyle(tint).font(.title3)
            Text(value).font(DMFont.calloutEmphasized())
            Text(label).font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var publicationsSection: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("Tus publicaciones")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
            ForEach(0..<2, id: \.self) { _ in
                pubCard(title: "Derivada", category: "Calculo diferencial", question: "Halla la derivada de sen(X/2)")
            }
        }
    }

    private func pubCard(title: String, category: String, question: String) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(DMFont.calloutEmphasized())
                    Text(category).font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.dmTextSecondary)
            }
            Text(question).font(DMFont.headline()).padding(.top, DMSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var menuCard: some View {
        VStack(spacing: 0) {
            MenuRow(icon: "medal", title: L10n.profileBadges, color: Color.dmWarning) {
                navigation.pushProfile(.badges)
            }
            Divider()
            MenuRow(icon: "chart.bar", title: L10n.profileStats, color: Color.dmSuccess) {
                navigation.pushProfile(.stats)
            }
            if appState.isModerator {
                Divider()
                MenuRow(icon: "shield.checkered", title: L10n.profileModeratorPanel, color: Color.dmPrimary) {
                    navigation.pushProfile(.moderatorDashboard)
                }
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.xs)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var dangerCard: some View {
        VStack(spacing: 0) {
            MenuRow(icon: "trash", title: L10n.profileDeleteAccount, color: Color.dmError) {
                showDeleteConfirmation = true
            }
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.xs)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(DMFont.headline())
            Text(title).font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.md)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DMSpacing.sm) {
                Image(systemName: icon).font(.body).foregroundStyle(color).frame(width: 24)
                Text(title).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Color.dmTextSecondary)
            }
            .padding(.vertical, DMSpacing.sm)
        }
    }
}
