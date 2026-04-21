import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var user: UserProfile? { appState.currentUser }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: DMSpacing.md) {
                    topBar
                    userHeader
                    generalSection
                    supportSection
                    Spacer(minLength: DMSpacing.xxl)
                }
                .padding(.horizontal, DMSpacing.lg)
            }
        }
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Configuración").font(DMFont.title2())
                }
                .foregroundStyle(Color.dmOnDark)
            }
            Spacer()
        }
        .padding(.top, DMSpacing.sm)
    }

    private var userHeader: some View {
        HStack(spacing: DMSpacing.sm) {
            Circle()
                .fill(LinearGradient(colors: [Color.dmPrimary, Color.dmSuccess],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .overlay(Text(user?.displayName?.prefix(1).uppercased() ?? "?").foregroundStyle(.white).font(DMFont.headline()))
            VStack(alignment: .leading, spacing: 2) {
                Text(user?.displayName ?? "Usuario demo").font(DMFont.headline())
                Text(user?.email ?? "usuario@dailymath.com")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
        }
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("General").font(DMFont.footnote()).foregroundStyle(Color.dmTextSecondary)
            VStack(spacing: 0) {
                settingsRow(icon: "person.fill", iconBg: Color.dmPrimary, title: "Perfil") { }
                Divider().padding(.leading, 56)
                settingsRow(icon: "lock.fill", iconBg: Color.dmError, title: "Seguridad") { }
            }
            .background(Color.dmSurface)
            .cornerRadius(DMRadius.lg)
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("Soporte").font(DMFont.footnote()).foregroundStyle(Color.dmTextSecondary)
            VStack(spacing: 0) {
                settingsRow(icon: "headphones", iconBg: Color.dmPrimary, title: "Centro de ayuda") { }
                Divider().padding(.leading, 56)
                settingsRow(icon: "bubble.left.fill", iconBg: Color.dmError, title: "Sugerencias") { }
            }
            .background(Color.dmSurface)
            .cornerRadius(DMRadius.lg)
        }
    }

    private func settingsRow(icon: String, iconBg: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DMSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(iconBg).frame(width: 32, height: 32)
                    Image(systemName: icon).foregroundStyle(.white).font(.footnote)
                }
                Text(title).foregroundStyle(.primary).font(DMFont.body())
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color.dmTextSecondary).font(.caption)
            }
            .padding(DMSpacing.md)
        }
    }
}
