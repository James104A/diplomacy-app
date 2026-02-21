import Foundation

// MARK: - JSON-based Territory Data
// Loads all territory definitions from territories.json at startup.

enum TerritoryData {

    // Loaded once at startup
    static let all: [Territory] = loadedTerritories
    static let hitTester: TerritoryHitTester = TerritoryHitTester(territories: all)

    // Adjacency graph built from JSON data (bidirectional)
    static let adjacencies: [String: Set<String>] = {
        var graph: [String: Set<String>] = [:]
        for t in all {
            graph[t.id] = Set(t.adjacencies)
        }
        // Mirror edges for bidirectional lookup
        for t in all {
            for adj in t.adjacencies {
                graph[adj, default: []].insert(t.id)
            }
        }
        return graph
    }()

    static func territory(for id: String) -> Territory? {
        all.first { $0.id == id }
    }

    static func adjacentTerritories(for id: String) -> [Territory] {
        guard let neighbors = adjacencies[id] else { return [] }
        return neighbors.compactMap { territory(for: $0) }
    }
}

// MARK: - JSON Loading

private let loadedTerritories: [Territory] = {
    #if DEBUG
    let start = CFAbsoluteTimeGetCurrent()
    #endif

    guard let url = Bundle.main.url(forResource: "territories", withExtension: "json") else {
        fatalError("territories.json not found in bundle")
    }
    guard let data = try? Data(contentsOf: url) else {
        fatalError("Failed to read territories.json")
    }
    guard let map = try? JSONDecoder().decode(TerritoryMap.self, from: data) else {
        fatalError("Failed to decode territories.json")
    }

    var territories: [Territory] = []
    for dto in map.territories {
        let territory = dto.toTerritory()
        territories.append(territory)

        // Generate coast variant entries as child territories
        if let coasts = dto.coasts {
            for coast in coasts {
                let coastTerritory = Territory(
                    id: coast.id.replacingOccurrences(of: "/", with: "_"),
                    name: coast.name,
                    type: .coast,
                    isSupplyCenter: false,
                    homeCenter: nil,
                    center: territory.unitAnchor,
                    parentTerritory: dto.id,
                    adjacencies: coast.adjacencies
                )
                territories.append(coastTerritory)
            }
        }
    }

    #if DEBUG
    let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
    print("territories.json loaded in \(String(format: "%.1f", elapsed))ms — \(territories.count) entries")
    #endif

    return territories
}()

// MARK: - Codable DTOs (internal to loader)

private struct TerritoryMap: Decodable {
    let version: String
    let mapAspectRatio: Double
    let territories: [TerritoryDTO]
}

private struct TerritoryDTO: Decodable {
    let id: String
    let name: String
    let type: String
    let isSupplyCenter: Bool
    let homeCountry: String?
    let labelAnchor: [Double]
    let unitAnchor: [Double]
    let polygon: [[Double]]?
    let adjacencies: [String]
    let coasts: [CoastDTO]?
    let disambiguationPriority: Int

    func toTerritory() -> Territory {
        let ttype: TerritoryType
        switch type {
        case "land": ttype = .land
        case "coast": ttype = .coast
        case "sea": ttype = .sea
        default: ttype = .land
        }

        let power: Power? = homeCountry.flatMap { Power(rawValue: $0.uppercased()) }

        let labelPt = CGPoint(x: labelAnchor[0], y: labelAnchor[1])
        let unitPt = CGPoint(x: unitAnchor[0], y: unitAnchor[1])

        let poly: [CGPoint]? = polygon?.map { CGPoint(x: $0[0], y: $0[1]) }

        let coastVariants: [CoastVariant]? = coasts?.map {
            CoastVariant(id: $0.id, name: $0.name, adjacencies: $0.adjacencies)
        }

        return Territory(
            id: id,
            name: name,
            type: ttype,
            isSupplyCenter: isSupplyCenter,
            homeCenter: power,
            labelAnchor: labelPt,
            unitAnchor: unitPt,
            parentTerritory: nil,
            polygon: poly,
            adjacencies: adjacencies,
            coasts: coastVariants,
            disambiguationPriority: disambiguationPriority
        )
    }
}

private struct CoastDTO: Decodable {
    let id: String
    let name: String
    let adjacencies: [String]
}
