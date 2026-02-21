import Foundation
import SwiftUI

// MARK: - Game State Response (from GET /v1/games/{gameId})

struct GameStateResponse: Decodable {
    let game: GameResponse
    let units: [UnitDto]
    let supplyCenters: [String: String?]
    let dislodgedUnits: [DislodgedUnitDto]?
}

struct UnitDto: Decodable, Equatable {
    let power: String
    let type: String // "ARMY" or "FLEET"
    let territoryId: String

    var powerEnum: Power? { Power(rawValue: power) }
    var isArmy: Bool { type == "ARMY" }
    var isFleet: Bool { type == "FLEET" }
}

struct DislodgedUnitDto: Decodable {
    let power: String
    let type: String
    let territoryId: String
    let attackedFrom: String
}

// MARK: - Order DTOs

struct SubmitOrdersRequest: Encodable {
    let orders: [OrderDto]
}

struct OrderDto: Codable, Equatable, Identifiable {
    var id: String { "\(type)_\(origin ?? "")_\(destination ?? "")" }

    let type: String // HOLD, MOVE, SUPPORT, CONVOY, BUILD, DISBAND, RETREAT
    var origin: String?
    var destination: String?
    var supportTarget: SupportTargetDto?
    var convoyTarget: ConvoyTargetDto?
    var territory: String?
    var unitType: String?
    var coast: String?
    var viaConvoy: Bool = false
}

struct SupportTargetDto: Codable, Equatable {
    let origin: String
    let destination: String?
}

struct ConvoyTargetDto: Codable, Equatable {
    let origin: String
    let destination: String
}

struct OrderSubmissionResponse: Decodable {
    let submitted: Bool
    let submittedAt: Date
    let validationResults: [OrderValidationResult]
}

struct OrderValidationResult: Decodable, Identifiable {
    let order: String
    let status: String // VALID, WARNING, INVALID
    let warning: String?
    let error: String?

    var id: String { order }
}

// MARK: - Order Type

enum OrderType: String, CaseIterable {
    case hold = "HOLD"
    case move = "MOVE"
    case support = "SUPPORT"
    case convoy = "CONVOY"

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .hold: return "shield"
        case .move: return "arrow.right"
        case .support: return "person.2"
        case .convoy: return "water.waves"
        }
    }
}

// MARK: - Territory Definition

enum TerritoryType: String {
    case land
    case coast
    case sea
}

struct Territory: Identifiable {
    let id: String
    let name: String
    let type: TerritoryType
    let isSupplyCenter: Bool
    let homeCenter: Power?
    let center: CGPoint // Normalized map position (0-1 range), same as unitAnchor
    let labelAnchor: CGPoint // Where to draw territory label
    let unitAnchor: CGPoint // Where to draw unit icon
    let parentTerritory: String?
    let polygon: [CGPoint]? // Boundary vertices in normalized 0-1 coordinates
    let adjacencies: [String] // Adjacent territory IDs
    let coasts: [CoastVariant]? // For multi-coast territories (BUL, SPA, STP)
    let disambiguationPriority: Int // 0 = highest (land), 10 = sea

    init(id: String, name: String, type: TerritoryType, isSupplyCenter: Bool, homeCenter: Power?, center: CGPoint, parentTerritory: String?, polygon: [CGPoint]? = nil, adjacencies: [String] = [], coasts: [CoastVariant]? = nil, disambiguationPriority: Int = 0) {
        self.id = id
        self.name = name
        self.type = type
        self.isSupplyCenter = isSupplyCenter
        self.homeCenter = homeCenter
        self.center = center
        self.labelAnchor = center
        self.unitAnchor = center
        self.parentTerritory = parentTerritory
        self.polygon = polygon
        self.adjacencies = adjacencies
        self.coasts = coasts
        self.disambiguationPriority = disambiguationPriority
    }

    init(id: String, name: String, type: TerritoryType, isSupplyCenter: Bool, homeCenter: Power?, labelAnchor: CGPoint, unitAnchor: CGPoint, parentTerritory: String?, polygon: [CGPoint]?, adjacencies: [String], coasts: [CoastVariant]?, disambiguationPriority: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.isSupplyCenter = isSupplyCenter
        self.homeCenter = homeCenter
        self.center = unitAnchor
        self.labelAnchor = labelAnchor
        self.unitAnchor = unitAnchor
        self.parentTerritory = parentTerritory
        self.polygon = polygon
        self.adjacencies = adjacencies
        self.coasts = coasts
        self.disambiguationPriority = disambiguationPriority
    }

    var isLand: Bool { type == .land || type == .coast }
    var isSea: Bool { type == .sea }
    var abbreviation: String { id }
}

struct CoastVariant {
    let id: String    // e.g. "BUL/EC"
    let name: String  // e.g. "Bulgaria (East Coast)"
    let adjacencies: [String]
}
