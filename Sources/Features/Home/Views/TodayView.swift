import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var showNotifications = false

    private var store: any FlashcardRepository { appState.flashcardStore }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: DMSpacing.lg) {
                    header
                    statsRow
                    if !store.dueFlashcards.isEmpty { quizCard }
                    flashcardSection
                }
                .padding(.horizontal, DMSpacing.lg)
                .padding(.top, DMSpacing.sm)
                .padding(.bottom, DMSpacing.xxl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showNotifications = true } label: {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color.dmOnDark)
                }
            }
        }
        .fullScreenCover(item: $navigation.homeFullScreen) { screen in
            switch screen {
            case .flashcardQuiz:
                FlashcardQuizView(cards: store.dueFlashcards)
                    .environmentObject(appState)
                    .environmentObject(navigation)
            }
        }
        .sheet(item: $navigation.homeSheet) { sheet in
            switch sheet {
            case .createFlashcard:
                CreateFlashcardView()
                    .environmentObject(appState)
                    .environmentObject(navigation)
            }
        }
        .sheet(isPresented: $showNotifications) { NotificationsView() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hoy")
                .font(DMFont.largeTitle())
            Text("¡Hola, \(appState.currentUser?.displayName ?? "")!")
                .font(DMFont.title3())
            Text("Tus tarjetas de repaso del día")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
                .padding(.top, 2)
        }
    }

    private var statsRow: some View {
        HStack(spacing: DMSpacing.sm) {
            statCard(value: "\(store.dueFlashcards.count)", label: "Pendientes", icon: "clock.fill", tint: Color.dmError)
            statCard(value: "\(store.totalReviewedToday)", label: "Pendientes", icon: "checkmark.circle.fill", tint: Color.dmSuccess)
            statCard(value: "\(store.flashcards.count)", label: "Pendientes", icon: "square.stack.3d.up.fill", tint: Color.dmPrimary)
        }
    }

    private func statCard(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: DMSpacing.xs) {
            Image(systemName: icon).foregroundStyle(tint).font(.title3)
            Text(value).font(DMFont.title2())
            Text(label).font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var quizCard: some View {
        Button {
            navigation.presentHomeFullScreen(.flashcardQuiz)
        } label: {
            HStack(spacing: DMSpacing.md) {
                Image(systemName: "play.circle.fill").font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Comenzar Quiz").font(DMFont.headline())
                    Text("\(store.dueFlashcards.count) tarjetas pendientes").font(DMFont.footnote()).opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding(DMSpacing.md)
            .frame(maxWidth: .infinity)
            .background(Color.dmSuccess)
            .cornerRadius(DMRadius.lg)
        }
    }

    private var flashcardSection: some View {
        VStack(alignment: .leading, spacing: DMSpacing.sm) {
            HStack {
                Text("Mis Flashcards").font(DMFont.calloutEmphasized())
                Spacer()
                Button {
                    navigation.presentHomeSheet(.createFlashcard)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.dmSuccess)
                        .font(.title3)
                }
            }
            if store.flashcards.isEmpty {
                VStack(spacing: DMSpacing.sm) {
                    Image(systemName: "sparkles").font(.system(size: 48)).foregroundStyle(Color.dmTextSecondary)
                    Text("Sin flashcards todavía").font(DMFont.headline())
                    Button {
                        navigation.presentHomeSheet(.createFlashcard)
                    } label: {
                        Text("Crear primera").secondaryButton()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(DMSpacing.lg)
                .background(Color.dmSurface)
                .cornerRadius(DMRadius.lg)
            } else {
                ForEach(store.flashcards) { card in flashcardRow(card) }
            }
        }
    }

    private func flashcardRow(_ card: QuizFlashcard) -> some View {
        HStack(spacing: DMSpacing.sm) {
            Circle()
                .fill(card.isDueToday ? Color.dmSuccess : Color.dmTextSecondary.opacity(0.4))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(card.question).font(DMFont.calloutEmphasized()).lineLimit(2)
                Text(card.isDueToday ? "Pendiente" : "Al día").font(DMFont.caption()).foregroundStyle(Color.dmTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Color.dmTextSecondary)
        }
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }
}
