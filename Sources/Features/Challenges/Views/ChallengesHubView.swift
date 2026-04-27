import SwiftUI

struct ChallengesHubView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Competir").font(DMFont.largeTitle())
                        Text("Desafia a otros estudiantes")
                            .font(DMFont.callout())
                            .foregroundStyle(Color.dmTextSecondary)
                    }
                    .padding(.top, DMSpacing.sm)

                    duelCard
                    inviteCard

                    Text("Torneos Semanales")
                        .font(DMFont.title2())
                        .padding(.top, DMSpacing.sm)

                    tournamentRow
                }
                .padding(.horizontal, DMSpacing.lg)
                .padding(.bottom, DMSpacing.xxl)
            }
        }
        .navigationBarHidden(true)
    }

    private var duelCard: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("DUELO MATEMÁTICO")
                .font(DMFont.caption2())
                .foregroundStyle(Color.dmTextSecondary)
            Text("Reta a otro\nestudiante")
                .font(DMFont.title2())
            Text("Resuelve ejercicios más rápido que tu oponente.")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
            Button {
                navigation.pushChallenges(.duelLobby)
            } label: {
                Text("Buscar Rival").secondaryButton()
            }
            .padding(.top, DMSpacing.xs)
        }
        .padding(DMSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var inviteCard: some View {
        HStack(spacing: DMSpacing.sm) {
            ZStack {
                Circle().fill(Color.dmTextSecondary.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: "person.fill").foregroundStyle(Color.dmTextSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Invitar a un amigo").font(DMFont.calloutEmphasized())
                Text("Comparte un duelo privado.").font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
            Button { } label: {
                Text("Crear Duelo")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmSurface)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.vertical, DMSpacing.xs)
                    .background(Color.dmOnDark)
                    .cornerRadius(DMRadius.pill)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var tournamentRow: some View {
        HStack(spacing: DMSpacing.sm) {
            ZStack {
                Circle().stroke(Color.dmTextSecondary, lineWidth: 1).frame(width: 40, height: 40)
                Image(systemName: "checkmark").foregroundStyle(Color.dmOnDark)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Invitar a un amigo").font(DMFont.calloutEmphasized())
                Text("Comparte un duelo privado.").font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
            Button { } label: {
                Text("Ver")
                    .font(DMFont.footnote())
                    .foregroundStyle(Color.dmSurface)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.vertical, DMSpacing.xs)
                    .background(Color.dmOnDark)
                    .cornerRadius(DMRadius.pill)
            }
        }
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }
}
