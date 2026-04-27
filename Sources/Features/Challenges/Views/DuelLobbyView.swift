import SwiftUI

struct DuelLobbyView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var dotCount: Int = 0

    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: DMSpacing.lg) {
                Spacer()
                ZStack {
                    Circle().fill(Color.dmWarning).frame(width: 140, height: 140)
                    Text("⚔️").font(.system(size: 64))
                }
                VStack(spacing: DMSpacing.xs) {
                    Text("Buscando rival\(String(repeating: ".", count: dotCount))")
                        .font(DMFont.title2())
                    Text("Emparejando con un estudiante de\nnivel general similar")
                        .font(DMFont.footnote())
                        .foregroundStyle(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                Text("...").font(.title).foregroundStyle(Color.dmTextSecondary)
                Button { dismiss() } label: {
                    Text("Cancelar")
                        .font(DMFont.calloutEmphasized())
                        .foregroundStyle(Color.dmOnDark)
                        .padding(.horizontal, DMSpacing.xl)
                        .padding(.vertical, DMSpacing.sm)
                        .background(Color.dmSurface)
                        .cornerRadius(DMRadius.pill)
                }
                Spacer()
            }
            .padding(.horizontal, DMSpacing.lg)
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
        .task {
            // Simulate waiting for an opponent
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            navigation.pushChallenges(.activeDuel)
        }
    }
}
