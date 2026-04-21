import SwiftUI

struct ActiveDuelView: View {
    var userName: String = "Tú"
    var opponentName: String = "Diegue"
    var currentExercise: Int = 3
    var totalExercises: Int = 10
    var timeRemaining: String = "2:34"
    var score: String = "2-1"
    var exerciseText: String = "∫ xcos(x) dx"
    @State private var answer: String = "xsin(x) +"
    @State private var showHint = false

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topStatus
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.md)

                scoreBar
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.md)

                exerciseCard
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.md)

                answerField
                    .padding(.horizontal, DMSpacing.lg)
                    .padding(.top, DMSpacing.md)

                Button { } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                        Text("Enviar respuesta")
                    }
                    .accentButton()
                }
                .padding(.horizontal, DMSpacing.lg)
                .padding(.top, DMSpacing.md)

                Spacer()

                if showHint { hintChip.padding(.bottom, DMSpacing.lg) }
            }
        }
        .navigationBarHidden(true)
    }

    private var topStatus: some View {
        HStack {
            VStack {
                Text("😎").font(.title)
                Text(userName).font(DMFont.footnote()).foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
            VStack(spacing: 2) {
                Text(timeRemaining).font(DMFont.title())
                Text("Tiempo restante").font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
            VStack {
                Text("🦁").font(.title)
                Text(opponentName).font(DMFont.footnote()).foregroundStyle(Color.dmTextSecondary)
            }
        }
    }

    private var scoreBar: some View {
        HStack {
            Text(score)
                .font(DMFont.title2())
                .foregroundStyle(Color.dmSurface)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.dmOnDark)
                .cornerRadius(DMRadius.md)
        }
    }

    private var exerciseCard: some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            Text("EJERCICIO \(currentExercise) DE \(totalExercises)")
                .font(DMFont.caption2())
                .foregroundStyle(Color.dmTextSecondary)
            Text(exerciseText)
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DMSpacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var answerField: some View {
        TextField("Tu respuesta...", text: $answer)
            .font(DMFont.title3())
            .padding(DMSpacing.md)
            .background(Color.dmSurface)
            .cornerRadius(DMRadius.pill)
    }

    private var hintChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "lightbulb")
            Text("Usa integración por partes:  ∫u·dv = u·v-∫v·du")
                .font(DMFont.footnote())
        }
        .foregroundStyle(Color.dmWarning)
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.xs)
        .background(Color.dmWarning.opacity(0.1))
        .cornerRadius(DMRadius.pill)
    }
}
