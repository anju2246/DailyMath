import SwiftUI

struct DuelResultView: View {
    var won: Bool = true
    var correctAnswers: Int = 6
    var timeSpent: String = "1:47"
    var pointsEarned: Int = 85
    var opponentName: String = "Carlos"
    var onRematch: () -> Void = {}
    var onExit: () -> Void = {}

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: DMSpacing.lg) {
                Spacer()
                ZStack {
                    Circle().fill(Color.dmWarning).frame(width: 120, height: 120)
                    Image(systemName: won ? "trophy.fill" : "xmark")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                }
                Text(won ? "VICTORIA" : "DERROTA")
                    .font(DMFont.caption2())
                    .foregroundStyle(.white)
                    .padding(.horizontal, DMSpacing.md)
                    .padding(.vertical, 4)
                    .background(won ? Color.dmWarning : Color.dmError)
                    .cornerRadius(DMRadius.pill)

                VStack(spacing: DMSpacing.xs) {
                    Text(won ? "¡Ganaste el duelo!" : "Perdiste el duelo")
                        .font(DMFont.title())
                    Text("Resolviste \(correctAnswers) ejercicios\ncorrectamente y superaste a \(opponentName)")
                        .font(DMFont.footnote())
                        .foregroundStyle(Color.dmTextSecondary)
                        .multilineTextAlignment(.center)
                }

                statsRow

                HStack(spacing: DMSpacing.sm) {
                    Button(action: onRematch) {
                        Text("Revancha")
                            .font(DMFont.calloutEmphasized())
                            .foregroundStyle(Color.dmOnDark)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.dmWarning)
                            .cornerRadius(DMRadius.pill)
                    }
                    Button(action: onExit) {
                        Text("Volver")
                            .font(DMFont.calloutEmphasized())
                            .foregroundStyle(Color.dmOnDark)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.dmSurface)
                            .overlay(RoundedRectangle(cornerRadius: DMRadius.pill).stroke(Color.dmTextSecondary.opacity(0.3)))
                            .cornerRadius(DMRadius.pill)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, DMSpacing.lg)
        }
        .navigationBarHidden(true)
    }

    private var statsRow: some View {
        HStack(spacing: DMSpacing.sm) {
            statBox(value: "\(correctAnswers)", label: "Correctas")
            statBox(value: timeSpent, label: "Tiempo")
            statBox(value: "+\(pointsEarned)", label: "Puntos")
        }
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(DMFont.title2())
            Text(label).font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }
}
