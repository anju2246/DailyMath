import SwiftUI

// MARK: - Toast Model

struct Toast: Equatable {
    var message: String
    var style: ToastStyle = .error

    enum ToastStyle: Equatable {
        case error, success, warning, info

        var color: Color {
            switch self {
            case .error:   return .red
            case .success: return .green
            case .warning: return .orange
            case .info:    return .blue
            }
        }

        var icon: String {
            switch self {
            case .error:   return "xmark.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info:    return "info.circle.fill"
            }
        }
    }
}

// MARK: - Toast View (Snackbar visual)

struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.style.icon)
                .foregroundStyle(toast.style.color)
                .font(.title3)

            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(toast.style.color.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Toast View Modifier

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast {
                    ToastView(toast: toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 32)
                        .task(id: toast) {
                            try? await Task.sleep(for: .seconds(3))
                            withAnimation(.easeInOut(duration: 0.35)) {
                                self.toast = nil
                            }
                        }
                }
            }
            .animation(.spring(duration: 0.45), value: toast)
    }
}

// MARK: - View Extension

extension View {
    /// Attach a Snackbar/Toast to any view. Set `toast` to a `Toast` value to show it;
    /// it auto-dismisses after 3 seconds.
    func toast(item: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: item))
    }
}
