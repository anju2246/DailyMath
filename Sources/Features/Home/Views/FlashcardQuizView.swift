import SwiftUI

// MARK: - Flashcard Quiz View (Duolingo Style)

struct FlashcardQuizView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false
    @State private var correctCount = 0
    @State private var isFinished = false
    @State private var shuffledOptions: [String] = []
    
    let cards: [QuizFlashcard]
    
    private var currentCard: QuizFlashcard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var body: some View {
        NavigationStack {
            if isFinished {
                finishedView
            } else if let card = currentCard {
                quizContent(card: card)
            }
        }
    }
    
    // MARK: - Quiz Content
    
    private func quizContent(card: QuizFlashcard) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(cards.count))
                        .animation(.spring(), value: currentIndex)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Counter
            HStack {
                Text(L10n.quizProgress(currentIndex + 1, cards.count))
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label(L10n.quizCorrectCount(correctCount), systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
            
            // Category badge
            if let cat = AppConstants.Category(rawValue: card.category) {
                Label(cat.displayName, systemImage: cat.icon)
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(20)
            }
            
            // Question
            Text(card.question)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            Spacer()
            
            // Options
            VStack(spacing: 12) {
                ForEach(shuffledOptions, id: \.self) { option in
                    optionButton(option: option, card: card)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Continue button
            if showResult {
                Button {
                    nextCard()
                } label: {
                    Text(L10n.commonContinueUppercase)
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(L10n.quizTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.quizExit) { dismiss() }
            }
        }
        .onAppear {
            shuffledOptions = card.shuffledOptions
        }
        .animation(.spring(response: 0.3), value: showResult)
    }
    
    // MARK: - Option Button
    
    private func optionButton(option: String, card: QuizFlashcard) -> some View {
        let isCorrectOption = option == card.correctAnswer
        let isSelected = option == selectedAnswer
        
        let bgColor: Color = {
            guard showResult else {
                return Color(.systemGray5)
            }
            if isCorrectOption {
                return Color.green.opacity(0.2)
            }
            if isSelected && !isCorrectOption {
                return Color.red.opacity(0.2)
            }
            return Color(.systemGray5)
        }()
        
        let borderColor: Color = {
            guard showResult else {
                return Color(.systemGray4)
            }
            if isCorrectOption {
                return .green
            }
            if isSelected && !isCorrectOption {
                return .red
            }
            return Color(.systemGray4)
        }()
        
        let icon: String? = {
            guard showResult else { return nil }
            if isCorrectOption { return "checkmark.circle.fill" }
            if isSelected && !isCorrectOption { return "xmark.circle.fill" }
            return nil
        }()
        
        return Button {
            guard !showResult else { return }
            selectedAnswer = option
            showResult = true
            
            let wasCorrect = option == card.correctAnswer
            if wasCorrect { correctCount += 1 }
            appState.flashcardStore.review(id: card.id, wasCorrect: wasCorrect)
        } label: {
            HStack {
                Text(option)
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(isCorrectOption ? .green : .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(showResult)
        .animation(.easeInOut(duration: 0.2), value: showResult)
    }
    
    // MARK: - Finished View
    
    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: correctCount == cards.count ? "trophy.fill" : "star.fill")
                .font(.system(size: 72))
                .foregroundStyle(.yellow)
            
            Text(L10n.quizFinishedTitle)
                .font(.largeTitle.bold())
            
            // Score
            VStack(spacing: 8) {
                Text(L10n.quizScore(correctCount, cards.count))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                
                Text(L10n.quizCorrectAnswers)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Percentage
            let pct = cards.isEmpty ? 0 : Int((Double(correctCount) / Double(cards.count)) * 100)
            Text(L10n.quizPercentage(pct))
                .font(.title.bold())
                .foregroundStyle(pct >= 80 ? .green : pct >= 50 ? .orange : .red)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(L10n.quizBack)
                    .primaryButton()
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle(L10n.quizResultTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Logic
    
    private func nextCard() {
        selectedAnswer = nil
        showResult = false
        
        if currentIndex + 1 < cards.count {
            currentIndex += 1
            if let card = currentCard {
                shuffledOptions = card.shuffledOptions
            }
        } else {
            isFinished = true
        }
    }
}
