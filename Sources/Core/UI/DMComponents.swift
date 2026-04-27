import SwiftUI

struct DMBrandHeader: View {
    let tagline: String

    var body: some View {
        VStack(spacing: 6) {
            Text("DailyMath")
                .font(DMFont.largeTitle())
                .foregroundStyle(.primary)
            Text(tagline)
                .font(DMFont.callout())
                .foregroundStyle(Color.dmTextSecondary)
        }
    }
}

struct DMUnderlineField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var trailingIcon: String? = nil
    var onTrailingTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(DMFont.body())
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .textContentType(contentType)
                .autocorrectionDisabled(contentType == .emailAddress || isSecure)

                if let icon = trailingIcon {
                    Button {
                        onTrailingTap?()
                    } label: {
                        Image(systemName: icon)
                            .foregroundStyle(Color.dmTextSecondary)
                    }
                }
            }
            Rectangle()
                .fill(Color.dmTextSecondary.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct DMFormCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: DMSpacing.lg) {
            content
        }
        .padding(DMSpacing.lg)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.xl)
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 2)
    }
}

struct DMAlertCard: View {
    let title: String?
    let message: String
    let primaryTitle: String
    let onPrimary: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: DMSpacing.sm) {
                if let title {
                    Text(title)
                        .font(DMFont.headline())
                        .foregroundStyle(.primary)
                }
                Text(message)
                    .font(DMFont.callout())
                    .foregroundStyle(Color.dmTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: onPrimary) {
                    Text(primaryTitle).secondaryButton()
                }
                .padding(.top, DMSpacing.xs)
            }
            .padding(DMSpacing.lg)
            .background(Color.dmSurface)
            .cornerRadius(DMRadius.lg)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
            .padding(.horizontal, DMSpacing.xl)
        }
    }
}

struct DMPageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.dmOnDark : Color.dmTextSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct DMOTPField: View {
    @Binding var code: String
    var length: Int = 6
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                ForEach(0..<length, id: \.self) { i in
                    let char = i < code.count ? String(code[code.index(code.startIndex, offsetBy: i)]) : ""
                    Text(char)
                        .font(DMFont.title2())
                        .frame(width: 46, height: 54)
                        .background(Color.dmSurface)
                        .cornerRadius(DMRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: DMRadius.md)
                                .stroke(focused && i == code.count ? Color.dmPrimary : Color.clear, lineWidth: 2)
                        )
                }
            }
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.01)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.prefix(length).filter { $0.isNumber })
                }
        }
        .onTapGesture { focused = true }
    }
}
