import SwiftUI

struct OTPView: View {
    let email: String
    var onVerified: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var isVerifying = false

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Spacer()
                VStack(spacing: DMSpacing.sm) {
                    Text("¡Un paso más!")
                        .font(DMFont.title())
                        .foregroundStyle(.primary)
                    VStack(spacing: 2) {
                        Text("Escribe el codigo de verificación")
                            .font(DMFont.callout())
                            .foregroundStyle(Color.dmTextSecondary)
                        Text("que te enviamos a")
                            .font(DMFont.callout())
                            .foregroundStyle(Color.dmTextSecondary)
                        Text(email)
                            .font(DMFont.calloutEmphasized())
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, DMSpacing.lg)

                Spacer(minLength: DMSpacing.xl)
                DMOTPField(code: $code)
                Spacer()
                Button {
                    isVerifying = true
                    Task {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        isVerifying = false
                        onVerified()
                    }
                } label: {
                    if isVerifying {
                        ProgressView().tint(.white).primaryButton()
                    } else {
                        Text("Verificar mi cuenta").primaryButton()
                    }
                }
                .disabled(code.count < 6 || isVerifying)
                .padding(.horizontal, DMSpacing.lg)
                .padding(.bottom, DMSpacing.md)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button(L10n.commonBack) { dismiss() }
                .font(DMFont.callout())
                .foregroundStyle(Color.dmTextSecondary)
            Spacer()
        }
        .padding(.top, DMSpacing.md)
        .padding(.horizontal, DMSpacing.lg)
    }
}
