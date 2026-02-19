import SwiftUI

// MARK: - Numeric Keyboard (Duolingo Style)

struct NumericKeyboardView: View {
    @Binding var text: String
    var isDisabled: Bool = false
    var onSubmit: () -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Row 1: 1-3
            HStack(spacing: 8) {
                numericKey("1")
                numericKey("2")
                numericKey("3")
            }
            
            // Row 2: 4-6
            HStack(spacing: 8) {
                numericKey("4")
                numericKey("5")
                numericKey("6")
            }
            
            // Row 3: 7-9
            HStack(spacing: 8) {
                numericKey("7")
                numericKey("8")
                numericKey("9")
            }
            
            // Row 4: special keys
            HStack(spacing: 8) {
                // Negative sign / special
                specialKey("-") {
                    if text.isEmpty {
                        text = "-"
                    }
                }
                
                numericKey("0")
                
                // Backspace
                specialKey("delete.backward.fill", isSystemImage: true) {
                    if !text.isEmpty {
                        text.removeLast()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Key Components
    
    private func numericKey(_ digit: String) -> some View {
        Button {
            if !isDisabled {
                text += digit
            }
        } label: {
            Text(digit)
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(isDisabled ? .secondary : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemGray5))
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
    
    private func specialKey(
        _ label: String,
        isSystemImage: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            if !isDisabled { action() }
        }) {
            Group {
                if isSystemImage {
                    Image(systemName: label)
                        .font(.title2.bold())
                } else {
                    Text(label)
                        .font(.title.bold())
                }
            }
            .foregroundStyle(isDisabled ? .secondary : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(.systemGray4))
            .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}
