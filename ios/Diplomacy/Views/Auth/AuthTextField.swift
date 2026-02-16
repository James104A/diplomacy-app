import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(.appSecondaryBold)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .textContentType(textContentType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .font(.appSecondary)
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Spacing.xs)
                    .stroke(Color.appSecondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
