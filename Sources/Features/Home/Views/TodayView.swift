import SwiftUI
import Combine

// MARK: - Today View (Flashcard Hub)

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: AppNavigationCoordinator
    
    private var store: any FlashcardRepository { appState.flashcardStore }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header greeting
                    VStack(alignment: .leading, spacing: 8) {
                        Text("¡Hola, \(appState.currentUser?.displayName ?? "")!")
                            .font(.title.bold())
                        
                        Text("Tus tarjetas de repaso del día")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Stats cards
                    HStack(spacing: 12) {
                        statBadge(
                            value: "\(store.dueFlashcards.count)",
                            label: "Pendientes",
                            icon: "clock.fill",
                            color: .orange
                        )
                        statBadge(
                            value: "\(store.totalReviewedToday)",
                            label: "Repasadas hoy",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        statBadge(
                            value: "\(store.flashcards.count)",
                            label: "Total",
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
                                    Text("Comenzar Quiz")
                                        .font(.headline.bold())
                                    Text("\(store.dueFlashcards.count) tarjetas pendientes")
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
                            Text("Mis Flashcards")
                                .font(.headline)
                            Spacer()
                            Button {
                                navigation.presentHomeSheet(.createFlashcard)
                            } label: {
                                Label("Nueva", systemImage: "plus.circle.fill")
                                    .font(.subheadline.bold())
                            }
                        }
                        .padding(.horizontal)
                        
                        if store.flashcards.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                
                                Text("No hay flashcards aún")
                                    .font(.headline)
                                
                                Text("Crea tu primera flashcard para empezar a estudiar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    navigation.presentHomeSheet(.createFlashcard)
                                } label: {
                                    Text("+ Crear Flashcard")
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
            .navigationTitle("Hoy")
            .navigationBarTitleDisplayMode(.large)
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
                    
                    Text(card.isDueToday ? "Pendiente" : "Próximo: \(card.nextReviewDate.shortFormatted)")
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
