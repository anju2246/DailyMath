import SwiftUI

// MARK: - Today View (Flashcard Hub)

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var showNotifications = false

    private var store: any FlashcardRepository { appState.flashcardStore }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header greeting
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.homeGreeting(appState.currentUser?.displayName ?? L10n.commonUser))
                        .font(.title.bold())

                    Text(L10n.homeDailyCardsSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Stats cards
                HStack(spacing: 12) {
                    statBadge(
                        value: "\(store.dueFlashcards.count)",
                        label: L10n.homePending,
                        icon: "clock.fill",
                        color: .orange
                    )
                    statBadge(
                        value: "\(store.totalReviewedToday)",
                        label: L10n.commonReviewedToday,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    statBadge(
                        value: "\(store.flashcards.count)",
                        label: L10n.commonTotal,
                        icon: "rectangle.stack.fill",
                        color: .blue
                    )
                }
                .padding(.horizontal)

                // Quiz button
                if !store.dueFlashcards.isEmpty {
                    Button {
                        navigation.presentHomeFullScreen(.flashcardQuiz)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(L10n.homeStartQuiz)
                                    .font(.headline.bold())
                                Text(L10n.homePendingCards(store.dueFlashcards.count))
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }

                // Flashcard list
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(L10n.homeMyFlashcards)
                            .font(.headline)
                        Spacer()
                        Button {
                            navigation.presentHomeSheet(.createFlashcard)
                        } label: {
                            Label(L10n.homeNew, systemImage: "plus.circle.fill")
                                .font(.subheadline.bold())
                        }
                    }
                    .padding(.horizontal)

                    if store.flashcards.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)

                            Text(L10n.homeNoFlashcards)
                                .font(.headline)

                            Text(L10n.homeCreateFirstFlashcard)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Button {
                                navigation.presentHomeSheet(.createFlashcard)
                            } label: {
                                Text(L10n.homeCreateFlashcardCta)
                                    .secondaryButton()
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal)
                    } else {
                        ForEach(store.flashcards) { card in
                            flashcardRow(card)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
            .padding(.bottom, 40)
        }
        .navigationTitle(L10n.tabToday)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNotifications = true
                } label: {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(.orange)
                        .font(.headline)
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
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
    }

    // MARK: - Components

    private func statBadge(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    private func flashcardRow(_ card: QuizFlashcard) -> some View {
        HStack(spacing: 12) {
            // Due indicator
            Circle()
                .fill(card.isDueToday ? Color.orange : Color.green)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.question)
                    .font(.subheadline.bold())
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let cat = AppConstants.Category(rawValue: card.category) {
                        Text(cat.displayName)
                            .font(.caption2)
                            .foregroundStyle(.tint)
                    }

                    Text(card.isDueToday ? L10n.homeDue : L10n.homeNextReview(card.nextReviewDate.shortFormatted))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
