import Foundation

// MARK: - Classic Diplomacy Map Data
// All 75 territories with normalized center coordinates (0.0–1.0) for map rendering.
// Coordinates are approximate positions on the classic Diplomacy board.

enum TerritoryData {

    static let all: [Territory] = inland + coastal + sea

    // MARK: - Adjacency Graph
    // Key = territory ID, Value = set of adjacent territory IDs
    static let adjacencies: [String: Set<String>] = buildAdjacencyGraph()

    static func territory(for id: String) -> Territory? {
        all.first { $0.id == id }
    }

    static func adjacentTerritories(for id: String) -> [Territory] {
        guard let neighbors = adjacencies[id] else { return [] }
        return neighbors.compactMap { territory(for: $0) }
    }

    // MARK: - Inland Territories (14)

    static let inland: [Territory] = [
        Territory(id: "BOH", name: "Bohemia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.505, y: 0.395), parentTerritory: nil),
        Territory(id: "BUR", name: "Burgundy", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.345, y: 0.415), parentTerritory: nil),
        Territory(id: "GAL", name: "Galicia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.575, y: 0.370), parentTerritory: nil),
        Territory(id: "RUH", name: "Ruhr", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.395, y: 0.355), parentTerritory: nil),
        Territory(id: "SIL", name: "Silesia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.510, y: 0.340), parentTerritory: nil),
        Territory(id: "TYR", name: "Tyrolia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.455, y: 0.435), parentTerritory: nil),
        Territory(id: "UKR", name: "Ukraine", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.655, y: 0.340), parentTerritory: nil),
        Territory(id: "BUD", name: "Budapest", type: .land, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.555, y: 0.415), parentTerritory: nil),
        Territory(id: "MOS", name: "Moscow", type: .land, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.705, y: 0.235), parentTerritory: nil),
        Territory(id: "MUN", name: "Munich", type: .land, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.430, y: 0.390), parentTerritory: nil),
        Territory(id: "PAR", name: "Paris", type: .land, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.305, y: 0.415), parentTerritory: nil),
        Territory(id: "SER", name: "Serbia", type: .land, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.555, y: 0.500), parentTerritory: nil),
        Territory(id: "VIE", name: "Vienna", type: .land, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.505, y: 0.415), parentTerritory: nil),
        Territory(id: "WAR", name: "Warsaw", type: .land, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.575, y: 0.305), parentTerritory: nil),
    ]

    // MARK: - Coastal Territories (43)

    static let coastal: [Territory] = [
        // Home supply centers
        Territory(id: "ANK", name: "Ankara", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.740, y: 0.535), parentTerritory: nil),
        Territory(id: "BER", name: "Berlin", type: .coast, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.480, y: 0.305), parentTerritory: nil),
        Territory(id: "BRE", name: "Brest", type: .coast, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.255, y: 0.395), parentTerritory: nil),
        Territory(id: "CON", name: "Constantinople", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.635, y: 0.545), parentTerritory: nil),
        Territory(id: "EDI", name: "Edinburgh", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.275, y: 0.195), parentTerritory: nil),
        Territory(id: "KIE", name: "Kiel", type: .coast, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.430, y: 0.305), parentTerritory: nil),
        Territory(id: "LON", name: "London", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.305, y: 0.310), parentTerritory: nil),
        Territory(id: "LVP", name: "Liverpool", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.265, y: 0.250), parentTerritory: nil),
        Territory(id: "MAR", name: "Marseilles", type: .coast, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.355, y: 0.490), parentTerritory: nil),
        Territory(id: "NAP", name: "Naples", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.465, y: 0.560), parentTerritory: nil),
        Territory(id: "ROM", name: "Rome", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.440, y: 0.520), parentTerritory: nil),
        Territory(id: "SEV", name: "Sevastopol", type: .coast, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.695, y: 0.385), parentTerritory: nil),
        Territory(id: "SMY", name: "Smyrna", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.665, y: 0.580), parentTerritory: nil),
        Territory(id: "TRI", name: "Trieste", type: .coast, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.485, y: 0.460), parentTerritory: nil),
        Territory(id: "VEN", name: "Venice", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.440, y: 0.465), parentTerritory: nil),

        // Neutral supply centers
        Territory(id: "BEL", name: "Belgium", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.360, y: 0.330), parentTerritory: nil),
        Territory(id: "DEN", name: "Denmark", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.440, y: 0.250), parentTerritory: nil),
        Territory(id: "GRE", name: "Greece", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.565, y: 0.570), parentTerritory: nil),
        Territory(id: "HOL", name: "Holland", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.380, y: 0.310), parentTerritory: nil),
        Territory(id: "NWY", name: "Norway", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.430, y: 0.145), parentTerritory: nil),
        Territory(id: "POR", name: "Portugal", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.155, y: 0.530), parentTerritory: nil),
        Territory(id: "RUM", name: "Rumania", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.605, y: 0.440), parentTerritory: nil),
        Territory(id: "SWE", name: "Sweden", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.490, y: 0.170), parentTerritory: nil),
        Territory(id: "TUN", name: "Tunis", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.395, y: 0.630), parentTerritory: nil),

        // Multi-coast parent territories
        Territory(id: "BUL", name: "Bulgaria", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.595, y: 0.500), parentTerritory: nil),
        Territory(id: "SPA", name: "Spain", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.215, y: 0.530), parentTerritory: nil),
        Territory(id: "STP", name: "St. Petersburg", type: .coast, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.625, y: 0.130), parentTerritory: nil),

        // Multi-coast variants
        Territory(id: "BUL_EC", name: "Bulgaria (East Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.610, y: 0.510), parentTerritory: "BUL"),
        Territory(id: "BUL_SC", name: "Bulgaria (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.585, y: 0.520), parentTerritory: "BUL"),
        Territory(id: "SPA_NC", name: "Spain (North Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.215, y: 0.505), parentTerritory: "SPA"),
        Territory(id: "SPA_SC", name: "Spain (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.215, y: 0.555), parentTerritory: "SPA"),
        Territory(id: "STP_NC", name: "St. Petersburg (North Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.640, y: 0.105), parentTerritory: "STP"),
        Territory(id: "STP_SC", name: "St. Petersburg (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.610, y: 0.155), parentTerritory: "STP"),

        // Non-supply-center coastal territories
        Territory(id: "ALB", name: "Albania", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.535, y: 0.530), parentTerritory: nil),
        Territory(id: "APU", name: "Apulia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.480, y: 0.545), parentTerritory: nil),
        Territory(id: "ARM", name: "Armenia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.780, y: 0.500), parentTerritory: nil),
        Territory(id: "CLY", name: "Clyde", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.250, y: 0.175), parentTerritory: nil),
        Territory(id: "FIN", name: "Finland", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.570, y: 0.115), parentTerritory: nil),
        Territory(id: "GAS", name: "Gascony", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.275, y: 0.470), parentTerritory: nil),
        Territory(id: "LVN", name: "Livonia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.590, y: 0.225), parentTerritory: nil),
        Territory(id: "NAF", name: "North Africa", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.285, y: 0.660), parentTerritory: nil),
        Territory(id: "PIC", name: "Picardy", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.320, y: 0.360), parentTerritory: nil),
        Territory(id: "PIE", name: "Piedmont", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.400, y: 0.465), parentTerritory: nil),
        Territory(id: "PRU", name: "Prussia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.525, y: 0.280), parentTerritory: nil),
        Territory(id: "SYR", name: "Syria", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.770, y: 0.580), parentTerritory: nil),
        Territory(id: "TUS", name: "Tuscany", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.425, y: 0.495), parentTerritory: nil),
        Territory(id: "WAL", name: "Wales", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.265, y: 0.295), parentTerritory: nil),
        Territory(id: "YOR", name: "Yorkshire", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.295, y: 0.260), parentTerritory: nil),
    ]

    // MARK: - Sea Zones (19)

    static let sea: [Territory] = [
        Territory(id: "ADR", name: "Adriatic Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.490, y: 0.510), parentTerritory: nil),
        Territory(id: "AEG", name: "Aegean Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.610, y: 0.580), parentTerritory: nil),
        Territory(id: "BAL", name: "Baltic Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.510, y: 0.230), parentTerritory: nil),
        Territory(id: "BAR", name: "Barents Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.600, y: 0.040), parentTerritory: nil),
        Territory(id: "BLA", name: "Black Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.680, y: 0.465), parentTerritory: nil),
        Territory(id: "BOT", name: "Gulf of Bothnia", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.535, y: 0.155), parentTerritory: nil),
        Territory(id: "EAS", name: "Eastern Mediterranean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.665, y: 0.640), parentTerritory: nil),
        Territory(id: "ENG", name: "English Channel", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.285, y: 0.365), parentTerritory: nil),
        Territory(id: "GOL", name: "Gulf of Lyon", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.345, y: 0.545), parentTerritory: nil),
        Territory(id: "HEL", name: "Heligoland Bight", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.400, y: 0.275), parentTerritory: nil),
        Territory(id: "ION", name: "Ionian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.500, y: 0.600), parentTerritory: nil),
        Territory(id: "IRI", name: "Irish Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.220, y: 0.270), parentTerritory: nil),
        Territory(id: "MAO", name: "Mid-Atlantic Ocean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.155, y: 0.440), parentTerritory: nil),
        Territory(id: "NAO", name: "North Atlantic Ocean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.155, y: 0.180), parentTerritory: nil),
        Territory(id: "NTH", name: "North Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.345, y: 0.225), parentTerritory: nil),
        Territory(id: "NWG", name: "Norwegian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.370, y: 0.090), parentTerritory: nil),
        Territory(id: "SKA", name: "Skagerrak", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.420, y: 0.205), parentTerritory: nil),
        Territory(id: "TYS", name: "Tyrrhenian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.420, y: 0.570), parentTerritory: nil),
        Territory(id: "WES", name: "Western Mediterranean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.330, y: 0.610), parentTerritory: nil),
    ]

    // MARK: - Adjacency Graph Builder

    private static func buildAdjacencyGraph() -> [String: Set<String>] {
        // Bidirectional edges — define once, mirror automatically
        let edges: [(String, String)] = [
            // Sea-to-sea adjacencies
            ("NAO", "NWG"), ("NAO", "IRI"), ("NAO", "MAO"),
            ("NWG", "BAR"), ("NWG", "NTH"),
            ("BAR", "NTH"), ("BAR", "NWG"),
            ("NTH", "SKA"), ("NTH", "HEL"), ("NTH", "ENG"),
            ("SKA", "BAL"), ("SKA", "BOT"),
            ("BAL", "BOT"),
            ("ENG", "IRI"), ("ENG", "MAO"),
            ("MAO", "WES"), ("MAO", "GOL"),
            ("WES", "GOL"), ("WES", "TYS"),
            ("GOL", "TYS"),
            ("TYS", "ION"),
            ("ION", "ADR"), ("ION", "AEG"), ("ION", "EAS"),
            ("AEG", "EAS"), ("AEG", "BLA"),

            // Coastal/land adjacencies — England
            ("CLY", "EDI"), ("CLY", "LVP"), ("CLY", "NAO"), ("CLY", "NWG"),
            ("EDI", "YOR"), ("EDI", "NTH"), ("EDI", "NWG"), ("EDI", "CLY"),
            ("LVP", "YOR"), ("LVP", "WAL"), ("LVP", "IRI"), ("LVP", "NAO"),
            ("YOR", "LON"), ("YOR", "WAL"), ("YOR", "NTH"),
            ("LON", "WAL"), ("LON", "ENG"), ("LON", "NTH"),
            ("WAL", "ENG"), ("WAL", "IRI"),

            // France
            ("BRE", "PIC"), ("BRE", "PAR"), ("BRE", "GAS"), ("BRE", "ENG"), ("BRE", "MAO"),
            ("PIC", "PAR"), ("PIC", "BUR"), ("PIC", "BEL"), ("PIC", "ENG"),
            ("PAR", "BUR"), ("PAR", "GAS"),
            ("GAS", "BUR"), ("GAS", "MAR"), ("GAS", "SPA"), ("GAS", "SPA_NC"), ("GAS", "MAO"),
            ("MAR", "BUR"), ("MAR", "PIE"), ("MAR", "SPA"), ("MAR", "SPA_SC"), ("MAR", "GOL"),

            // Germany
            ("KIE", "BER"), ("KIE", "MUN"), ("KIE", "RUH"), ("KIE", "HOL"), ("KIE", "DEN"), ("KIE", "HEL"), ("KIE", "BAL"),
            ("BER", "MUN"), ("BER", "SIL"), ("BER", "PRU"), ("BER", "BAL"),
            ("MUN", "RUH"), ("MUN", "BUR"), ("MUN", "TYR"), ("MUN", "BOH"), ("MUN", "SIL"),
            ("RUH", "BEL"), ("RUH", "HOL"), ("RUH", "BUR"),

            // Low Countries
            ("BEL", "HOL"), ("BEL", "BUR"), ("BEL", "ENG"), ("BEL", "NTH"),
            ("HOL", "HEL"), ("HOL", "NTH"),
            ("DEN", "SKA"), ("DEN", "NTH"), ("DEN", "HEL"), ("DEN", "BAL"), ("DEN", "SWE"),

            // Scandinavia
            ("NWY", "SWE"), ("NWY", "FIN"), ("NWY", "STP"), ("NWY", "STP_NC"), ("NWY", "BAR"), ("NWY", "NWG"), ("NWY", "NTH"), ("NWY", "SKA"),
            ("SWE", "FIN"), ("SWE", "DEN"), ("SWE", "SKA"), ("SWE", "BAL"), ("SWE", "BOT"),
            ("FIN", "STP"), ("FIN", "STP_SC"), ("FIN", "BOT"),

            // Russia
            ("STP", "MOS"), ("STP", "LVN"), ("STP", "FIN"),
            ("STP_NC", "BAR"),
            ("STP_SC", "BOT"), ("STP_SC", "LVN"),
            ("MOS", "LVN"), ("MOS", "WAR"), ("MOS", "UKR"), ("MOS", "SEV"),
            ("LVN", "WAR"), ("LVN", "PRU"), ("LVN", "BAL"), ("LVN", "BOT"),
            ("WAR", "PRU"), ("WAR", "SIL"), ("WAR", "GAL"), ("WAR", "UKR"),
            ("SEV", "UKR"), ("SEV", "RUM"), ("SEV", "ARM"), ("SEV", "BLA"),
            ("UKR", "GAL"), ("UKR", "RUM"),

            // Austria
            ("VIE", "BOH"), ("VIE", "TYR"), ("VIE", "TRI"), ("VIE", "BUD"), ("VIE", "GAL"),
            ("BUD", "GAL"), ("BUD", "RUM"), ("BUD", "SER"), ("BUD", "TRI"),
            ("TRI", "TYR"), ("TRI", "VEN"), ("TRI", "SER"), ("TRI", "ALB"), ("TRI", "ADR"),
            ("BOH", "SIL"), ("BOH", "GAL"), ("BOH", "TYR"),

            // Italy
            ("VEN", "TYR"), ("VEN", "PIE"), ("VEN", "TUS"), ("VEN", "ROM"), ("VEN", "APU"), ("VEN", "ADR"),
            ("PIE", "TUS"), ("PIE", "TYR"), ("PIE", "GOL"),
            ("TUS", "ROM"), ("TUS", "GOL"), ("TUS", "TYS"),
            ("ROM", "NAP"), ("ROM", "APU"), ("ROM", "TYS"),
            ("NAP", "APU"), ("NAP", "ION"), ("NAP", "TYS"),
            ("APU", "ADR"), ("APU", "ION"),

            // Balkans
            ("SER", "RUM"), ("SER", "BUL"), ("SER", "GRE"), ("SER", "ALB"),
            ("ALB", "GRE"), ("ALB", "ION"), ("ALB", "ADR"),
            ("GRE", "BUL"), ("GRE", "BUL_SC"), ("GRE", "AEG"), ("GRE", "ION"),
            ("RUM", "BUL"), ("RUM", "BUL_EC"), ("RUM", "BLA"), ("RUM", "GAL"),
            ("BUL", "CON"),
            ("BUL_EC", "CON"), ("BUL_EC", "BLA"),
            ("BUL_SC", "CON"), ("BUL_SC", "AEG"),

            // Turkey
            ("CON", "SMY"), ("CON", "ANK"), ("CON", "BLA"), ("CON", "AEG"),
            ("SMY", "ANK"), ("SMY", "ARM"), ("SMY", "SYR"), ("SMY", "AEG"), ("SMY", "EAS"),
            ("ANK", "ARM"), ("ANK", "BLA"),
            ("ARM", "BLA"), ("ARM", "SYR"),
            ("SYR", "EAS"),

            // Iberia
            ("SPA", "POR"),
            ("SPA_NC", "POR"), ("SPA_NC", "MAO"),
            ("SPA_SC", "POR"), ("SPA_SC", "MAO"), ("SPA_SC", "WES"),
            ("POR", "MAO"),

            // North Africa
            ("NAF", "MAO"), ("NAF", "WES"), ("NAF", "TUN"),
            ("TUN", "WES"), ("TUN", "TYS"), ("TUN", "ION"),

            // PRU adjacencies
            ("PRU", "SIL"), ("PRU", "BAL"),
        ]

        var graph: [String: Set<String>] = [:]
        for t in all {
            graph[t.id] = []
        }

        for (a, b) in edges {
            graph[a, default: []].insert(b)
            graph[b, default: []].insert(a)
        }

        return graph
    }
}
