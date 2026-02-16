import SwiftUI

// MARK: - Button Styles

enum DiplomacyButtonStyle {
    case primary    // Blue #2E75B6
    case success    // Green #2D7A2D (Orders Submitted)
    case disabled   // Gray
    case destructive // Red
}

struct DiplomacyButton: View {
    let title: String
    let style: DiplomacyButtonStyle
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: hapticStyle)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.appSecondaryBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Spacing.touchTarget)
                .background(backgroundColor)
                .cornerRadius(Spacing.xs)
        }
        .disabled(style == .disabled)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .appPrimary
        case .success: return .appSuccess
        case .disabled: return .appSecondary.opacity(0.5)
        case .destructive: return .appError
        }
    }

    private var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch style {
        case .primary: return .light
        case .success: return .medium
        case .destructive: return .heavy
        case .disabled: return .light
        }
    }
}
