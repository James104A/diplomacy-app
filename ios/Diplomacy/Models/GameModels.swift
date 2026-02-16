import Foundation

// MARK: - Game Summary (Dashboard list item)

struct GameSummary: Decodable, Identifiable {
    let gameId: UUID
    let name: String
    let status: String
    let power: String
    let currentPhase: String
    let currentSeason: String
    let currentYear: Int
    let phaseDeadline: Date?
    let ordersSubmitted: Bool
    let supplyCenterCount: Int
    let prevSupplyCenterCount: Int
    let unreadMessageCount: Int
    let playerCount: Int

    var id: UUID { gameId }

    var phaseLabel: String {
        "\(currentSeason.capitalized) \(currentYear) — \(currentPhase.capitalized)"
    }

    var powerEnum: Power? {
        Power(rawValue: power)
    }

    var isEliminated: Bool {
        status == "ELIMINATED"
    }

    var cardState: GameCardState {
        if isEliminated { return .eliminated }
        if !ordersSubmitted && phaseDeadline != nil { return .needsOrders }
        if unreadMessageCount > 0 { return .unreadMessages }
        if ordersSubmitted { return .ordersSubmitted }
        return .waitingForResolution
    }
}

// MARK: - Create Game

struct CreateGameRequest: Encodable {
    let name: String
    var map: String = "CLASSIC"
    var phaseLength: String = "PT24H"
    var pressRules: String = "FULL_PRESS"
    var scoring: String = "DRAW_SIZE"
    var minReliability: Int = 70
    var ranked: Bool = true
    var visibility: String = "PRIVATE"
    var readReceipts: Bool = false
    var anonymousCountries: Bool = false
}

// MARK: - Game Response (full detail)

struct GameResponse: Decodable, Identifiable {
    let id: UUID
    let name: String
    let status: String
    let creatorId: UUID
    let settings: GameSettings
    let players: [GamePlayerSummary]
    let inviteCode: String?
    let currentPhase: String
    let currentSeason: String
    let currentYear: Int
    let phaseDeadline: Date?
    let createdAt: Date
    let startedAt: Date?
}

struct GameSettings: Decodable {
    let map: String
    let phaseLength: String
    let pressRules: String
    let scoring: String
    let minReliability: Int
    let ranked: Bool
    let readReceipts: Bool
    let anonymousCountries: Bool

    var phaseLengthDisplay: String {
        switch phaseLength {
        case "PT5M": return "5 minutes"
        case "PT15M": return "15 minutes"
        case "PT1H": return "1 hour"
        case "PT6H": return "6 hours"
        case "PT12H": return "12 hours"
        case "PT24H": return "24 hours"
        case "PT48H": return "48 hours"
        case "PT72H": return "3 days"
        case "P7D": return "7 days"
        default: return phaseLength
        }
    }

    var pressRulesDisplay: String {
        switch pressRules {
        case "FULL_PRESS": return "Full Press"
        case "GUNBOAT": return "Gunboat (No Chat)"
        case "RULE_BOOK": return "Rule Book Press"
        default: return pressRules
        }
    }
}

struct GamePlayerSummary: Decodable, Identifiable {
    let playerId: UUID
    let power: String
    let ordersSubmitted: Bool
    let isEliminated: Bool
    let supplyCenterCount: Int

    var id: UUID { playerId }

    var powerEnum: Power? {
        Power(rawValue: power)
    }
}

// MARK: - Phase Length Options

enum PhaseLength: String, CaseIterable, Identifiable {
    case fiveMin = "PT5M"
    case fifteenMin = "PT15M"
    case oneHour = "PT1H"
    case sixHours = "PT6H"
    case twelveHours = "PT12H"
    case twentyFourHours = "PT24H"
    case fortyEightHours = "PT48H"
    case threeDays = "PT72H"
    case sevenDays = "P7D"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fiveMin: return "5 minutes"
        case .fifteenMin: return "15 minutes"
        case .oneHour: return "1 hour"
        case .sixHours: return "6 hours"
        case .twelveHours: return "12 hours"
        case .twentyFourHours: return "24 hours"
        case .fortyEightHours: return "48 hours"
        case .threeDays: return "3 days"
        case .sevenDays: return "7 days"
        }
    }
}

// MARK: - Press Rules Options

enum PressRules: String, CaseIterable, Identifiable {
    case fullPress = "FULL_PRESS"
    case gunboat = "GUNBOAT"
    case ruleBook = "RULE_BOOK"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullPress: return "Full Press"
        case .gunboat: return "Gunboat (No Chat)"
        case .ruleBook: return "Rule Book Press"
        }
    }

    var description: String {
        switch self {
        case .fullPress: return "Players can freely message anyone"
        case .gunboat: return "No messaging between players"
        case .ruleBook: return "Public messages only, no private chats"
        }
    }
}
