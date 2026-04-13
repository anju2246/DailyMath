import SwiftUI
import Combine

// MARK: - Numeric Keyboard (Duolingo Style)

struct NumericKeyboardView: View {
    @Binding var text: String
    var isDisabled: Bool = false
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Row 1: 1-3
            HStack(spacing: 10) {
                numericKey("1")
                numericKey("2")
                numericKey("3")
            }
            
            // Row 2: 4-6
            HStack(spacing: 10) {
                numericKey("4")
                numericKey("5")
                numericKey("6")
            }
            
            // Row 3: 7-9
            HStack(spacing: 10) {
                numericKey("7")
                numericKey("8")
                numericKey("9")
            }
            
            // Row 4: special keys
            HStack(spacing: 10) {
                // Negative sign
                specialKey("-", color: Color(.systemGray3)) {
                    if text.isEmpty {
                        text = "-"
                    }
                }
                
                numericKey("0")
                
                // Backspace
                Button {
                    if !isDisabled && !text.isEmpty {
                        text.removeLast()
                    }
                } label: {
                    Image(systemName: "delete.backward.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(.systemGray3))
                        .cornerRadius(14)
                }
                .disabled(isDisabled)
            }
            
            // Submit button
            Button {
                if !isDisabled {
                    onSubmit()
                }
            } label: {
                Text(L10n.commonSendUppercase)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        text.isEmpty || isDisabled
                            ? Color.gray
                            : Color.green
                    )
                    .cornerRadius(14)
            }
            .disabled(text.isEmpty || isDisabled)
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.systemGray2))
                .cornerRadius(14)
        }
        .disabled(isDisabled)
    }
    
    private func specialKey(
        _ label: String,
        color: Color = Color(.systemGray3),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            if !isDisabled { action() }
        }) {
            Text(label)
                .font(.title.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(color)
                .cornerRadius(14)
        }
        .disabled(isDisabled)
    }
}
