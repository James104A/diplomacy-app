import Foundation

// MARK: - API Response / Request Body

struct NotificationPreferences: Codable {
    var global: GlobalNotificationPrefs
    var perGame: [String: GameNotificationPrefs]
}

struct GlobalNotificationPrefs: Codable {
    var newMessage: Bool
    var phaseResolved: String
    var deadlineReminder: String
    var ordersReminder: String
}

struct GameNotificationPrefs: Codable {
    var muted: Bool
    var overrides: GlobalNotificationPrefs?
}

// MARK: - Phase Resolved Options

enum PhaseResolvedOption: String, CaseIterable, Identifiable {
    case immediate = "IMMEDIATE"
    case dailyDigest = "DAILY_DIGEST"
    case off = "OFF"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .immediate: return "Immediate"
        case .dailyDigest: return "Daily digest"
        case .off: return "Off"
        }
    }
}

// MARK: - Reminder Duration Options

enum ReminderDuration: String, CaseIterable, Identifiable {
    case off = "OFF"
    case thirtyMin = "PT30M"
    case oneHour = "PT1H"
    case twoHours = "PT2H"
    case fourHours = "PT4H"
    case twelveHours = "PT12H"
    case oneDay = "PT24H"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .thirtyMin: return "30 minutes before"
        case .oneHour: return "1 hour before"
        case .twoHours: return "2 hours before"
        case .fourHours: return "4 hours before"
        case .twelveHours: return "12 hours before"
        case .oneDay: return "1 day before"
        }
    }
}
