import SwiftUI

// MARK: - Power Colors

enum PowerPalette: String, CaseIterable {
    case classic
    case highContrast
    case muted
}

enum Power: String, CaseIterable, Identifiable {
    case england = "ENGLAND"
    case france = "FRANCE"
    case germany = "GERMANY"
    case italy = "ITALY"
    case austria = "AUSTRIA"
    case russia = "RUSSIA"
    case turkey = "TURKEY"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    func color(palette: PowerPalette = .classic) -> Color {
        switch palette {
        case .classic:
            return classicColor
        case .highContrast:
            return highContrastColor
        case .muted:
            return mutedColor
        }
    }

    private var classicColor: Color {
        switch self {
        case .england: return Color(hex: 0x1E3A8A)
        case .france:  return Color(hex: 0x60A5FA)
        case .germany: return Color(hex: 0x6B7280)
        case .italy:   return Color(hex: 0x16A34A)
        case .austria: return Color(hex: 0xDC2626)
        case .russia:  return Color(hex: 0x7E22CE)
        case .turkey:  return Color(hex: 0xF59E0B)
        }
    }

    private var highContrastColor: Color {
        switch self {
        case .england: return Color(hex: 0x0000FF)
        case .france:  return Color(hex: 0x00BFFF)
        case .germany: return Color(hex: 0x808080)
        case .italy:   return Color(hex: 0x00FF00)
        case .austria: return Color(hex: 0xFF0000)
        case .russia:  return Color(hex: 0xFF00FF)
        case .turkey:  return Color(hex: 0xFFD700)
        }
    }

    private var mutedColor: Color {
        switch self {
        case .england: return Color(hex: 0x5B7BA5)
        case .france:  return Color(hex: 0x8EAEC0)
        case .germany: return Color(hex: 0xA0A0A0)
        case .italy:   return Color(hex: 0x6DAA7D)
        case .austria: return Color(hex: 0xC47070)
        case .russia:  return Color(hex: 0x9B7DB8)
        case .turkey:  return Color(hex: 0xC4A95B)
        }
    }

    /// Color-blind pattern overlay name
    var patternName: String {
        switch self {
        case .england: return "stripes"
        case .france:  return "dots"
        case .germany: return "crosshatch"
        case .italy:   return "chevrons"
        case .austria: return "diamonds"
        case .russia:  return "grid"
        case .turkey:  return "waves"
        }
    }
}

// MARK: - App Colors

extension Color {
    static let appPrimary = Color(hex: 0x2E75B6)
    static let appSecondary = Color(hex: 0x6B7280)
    static let appBackground = Color(.systemBackground)
    static let appGroupedBackground = Color(.systemGroupedBackground)
    static let appError = Color(hex: 0xDC2626)
    static let appSuccess = Color(hex: 0x2D7A2D)
    static let appWarning = Color(hex: 0xF59E0B)

    // Deadline urgency colors
    static let deadlineGreen = Color(hex: 0x16A34A)
    static let deadlineYellow = Color(hex: 0xF59E0B)
    static let deadlineRed = Color(hex: 0xDC2626)
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
