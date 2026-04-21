import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let imageSymbol: String
    let headline: String
    let body: String
}

struct OnboardingView: View {
    var onFinish: () -> Void = {}

    @State private var current: Int = 0

    private let pages: [OnboardingPage] = [
        .init(
            title: "Repetición Espaciada",
            imageSymbol: "brain.head.profile",
            headline: "Aprende con repetición inteligente",
            body: "Repasa ejercicios en el momento exacto para recordar más y estudiar menos."
        ),
        .init(
            title: "Comunidad",
            imageSymbol: "person.3.fill",
            headline: "Descubre y comparte ejercicios",
            body: "Explora problemas creados por estudiantes cerca de ti y guarda tus favoritos."
        ),
        .init(
            title: "Agilidad Mental",
            imageSymbol: "bolt.fill",
            headline: "Entrena tu mente cada día",
            body: "Mejora tu velocidad y precisión con sesiones rápidas de práctica."
        )
    ]

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: DMSpacing.xl)
                pageContent
                Spacer()
                DMPageIndicator(current: current, total: pages.count)
                    .padding(.bottom, DMSpacing.xl)

                if current == pages.count - 1 {
                    Button {
                        onFinish()
                    } label: {
                        Text("Empieza Ahora").primaryButton()
                    }
                    .padding(.horizontal, DMSpacing.xxl)
                    .padding(.bottom, DMSpacing.md)
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button("Saltar") { onFinish() }
                .font(DMFont.callout())
                .foregroundStyle(Color.dmTextSecondary)
        }
        .padding(.top, DMSpacing.md)
        .padding(.horizontal, DMSpacing.lg)
    }

    private var pageContent: some View {
        TabView(selection: $current) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { idx, page in
                VStack(spacing: DMSpacing.lg) {
                    Text(page.title)
                        .font(DMFont.title())
                        .foregroundStyle(.primary)

                    Image(systemName: page.imageSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .foregroundStyle(Color.dmTextSecondary.opacity(0.4))
                        .padding(DMSpacing.xl)
                        .background(Color.dmTextSecondary.opacity(0.15))
                        .cornerRadius(DMRadius.md)

                    VStack(spacing: DMSpacing.sm) {
                        Text(page.headline)
                            .font(DMFont.headline())
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        Text(page.body)
                            .font(DMFont.callout())
                            .foregroundStyle(Color.dmTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DMSpacing.lg)
                    }
                }
                .padding(.horizontal, DMSpacing.lg)
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: 500)
    }
}
