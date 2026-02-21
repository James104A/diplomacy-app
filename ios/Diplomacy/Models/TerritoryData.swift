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

    /// Look up polygon boundary for a territory. Coast variants return nil.
    private static func poly(_ id: String) -> [CGPoint]? {
        TerritoryPolygonData.boundaries[id]
    }

    // MARK: - Inland Territories (14)

    static let inland: [Territory] = [
        Territory(id: "BOH", name: "Bohemia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4431, y: 0.6096), parentTerritory: nil, polygon: poly("BOH")),
        Territory(id: "BUR", name: "Burgundy", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3051, y: 0.6511), parentTerritory: nil, polygon: poly("BUR")),
        Territory(id: "GAL", name: "Galicia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5442, y: 0.621), parentTerritory: nil, polygon: poly("GAL")),
        Territory(id: "RUH", name: "Ruhr", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3516, y: 0.5846), parentTerritory: nil, polygon: poly("RUH")),
        Territory(id: "SIL", name: "Silesia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4582, y: 0.5723), parentTerritory: nil, polygon: poly("SIL")),
        Territory(id: "TYR", name: "Tyrolia", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4086, y: 0.6734), parentTerritory: nil, polygon: poly("TYR")),
        Territory(id: "UKR", name: "Ukraine", type: .land, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.6202, y: 0.5919), parentTerritory: nil, polygon: poly("UKR")),
        Territory(id: "BUD", name: "Budapest", type: .land, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.5244, y: 0.686), parentTerritory: nil, polygon: poly("BUD")),
        Territory(id: "MOS", name: "Moscow", type: .land, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.8438, y: 0.4248), parentTerritory: nil, polygon: poly("MOS")),
        Territory(id: "MUN", name: "Munich", type: .land, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.3849, y: 0.6204), parentTerritory: nil, polygon: poly("MUN")),
        Territory(id: "PAR", name: "Paris", type: .land, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.2732, y: 0.6249), parentTerritory: nil, polygon: poly("PAR")),
        Territory(id: "SER", name: "Serbia", type: .land, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.5203, y: 0.784), parentTerritory: nil, polygon: poly("SER")),
        Territory(id: "VIE", name: "Vienna", type: .land, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.4653, y: 0.6503), parentTerritory: nil, polygon: poly("VIE")),
        Territory(id: "WAR", name: "Warsaw", type: .land, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.5267, y: 0.5555), parentTerritory: nil, polygon: poly("WAR")),
    ]

    // MARK: - Coastal Territories (43)

    static let coastal: [Territory] = [
        // Home supply centers
        Territory(id: "ANK", name: "Ankara", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.7181, y: 0.8225), parentTerritory: nil, polygon: poly("ANK")),
        Territory(id: "BER", name: "Berlin", type: .coast, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.4245, y: 0.5274), parentTerritory: nil, polygon: poly("BER")),
        Territory(id: "BRE", name: "Brest", type: .coast, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.2314, y: 0.6088), parentTerritory: nil, polygon: poly("BRE")),
        Territory(id: "CON", name: "Constantinople", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.6356, y: 0.8537), parentTerritory: nil, polygon: poly("CON")),
        Territory(id: "EDI", name: "Edinburgh", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.2653, y: 0.3805), parentTerritory: nil, polygon: poly("EDI")),
        Territory(id: "KIE", name: "Kiel", type: .coast, isSupplyCenter: true, homeCenter: .germany, center: CGPoint(x: 0.3807, y: 0.5276), parentTerritory: nil, polygon: poly("KIE")),
        Territory(id: "LON", name: "London", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.271, y: 0.5168), parentTerritory: nil, polygon: poly("LON")),
        Territory(id: "LVP", name: "Liverpool", type: .coast, isSupplyCenter: true, homeCenter: .england, center: CGPoint(x: 0.25, y: 0.4295), parentTerritory: nil, polygon: poly("LVP")),
        Territory(id: "MAR", name: "Marseilles", type: .coast, isSupplyCenter: true, homeCenter: .france, center: CGPoint(x: 0.2973, y: 0.7276), parentTerritory: nil, polygon: poly("MAR")),
        Territory(id: "NAP", name: "Naples", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.4418, y: 0.8678), parentTerritory: nil, polygon: poly("NAP")),
        Territory(id: "ROM", name: "Rome", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.4031, y: 0.8084), parentTerritory: nil, polygon: poly("ROM")),
        Territory(id: "SEV", name: "Sevastopol", type: .coast, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.773, y: 0.6524), parentTerritory: nil, polygon: poly("SEV")),
        Territory(id: "SMY", name: "Smyrna", type: .coast, isSupplyCenter: true, homeCenter: .turkey, center: CGPoint(x: 0.6987, y: 0.8918), parentTerritory: nil, polygon: poly("SMY")),
        Territory(id: "TRI", name: "Trieste", type: .coast, isSupplyCenter: true, homeCenter: .austria, center: CGPoint(x: 0.4594, y: 0.7388), parentTerritory: nil, polygon: poly("TRI")),
        Territory(id: "VEN", name: "Venice", type: .coast, isSupplyCenter: true, homeCenter: .italy, center: CGPoint(x: 0.3982, y: 0.7406), parentTerritory: nil, polygon: poly("VEN")),

        // Neutral supply centers
        Territory(id: "BEL", name: "Belgium", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.3109, y: 0.5659), parentTerritory: nil, polygon: poly("BEL")),
        Territory(id: "DEN", name: "Denmark", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.3967, y: 0.4369), parentTerritory: nil, polygon: poly("DEN")),
        Territory(id: "GRE", name: "Greece", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.5397, y: 0.8819), parentTerritory: nil, polygon: poly("GRE")),
        Territory(id: "HOL", name: "Holland", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.3366, y: 0.5276), parentTerritory: nil, polygon: poly("HOL")),
        Territory(id: "NWY", name: "Norway", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.4343, y: 0.2504), parentTerritory: nil, polygon: poly("NWY")),
        Territory(id: "POR", name: "Portugal", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.0992, y: 0.7762), parentTerritory: nil, polygon: poly("POR")),
        Territory(id: "RUM", name: "Rumania", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.5909, y: 0.723), parentTerritory: nil, polygon: poly("RUM")),
        Territory(id: "SWE", name: "Sweden", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.4708, y: 0.2883), parentTerritory: nil, polygon: poly("SWE")),
        Territory(id: "TUN", name: "Tunis", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.344, y: 0.9644), parentTerritory: nil, polygon: poly("TUN")),

        // Multi-coast parent territories
        Territory(id: "BUL", name: "Bulgaria", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.5775, y: 0.7943), parentTerritory: nil, polygon: poly("BUL")),
        Territory(id: "SPA", name: "Spain", type: .coast, isSupplyCenter: true, homeCenter: nil, center: CGPoint(x: 0.1671, y: 0.7851), parentTerritory: nil, polygon: poly("SPA")),
        Territory(id: "STP", name: "St. Petersburg", type: .coast, isSupplyCenter: true, homeCenter: .russia, center: CGPoint(x: 0.7439, y: 0.1962), parentTerritory: nil, polygon: poly("STP")),

        // Multi-coast variants (no polygon — parent territory renders the shape)
        Territory(id: "BUL_EC", name: "Bulgaria (East Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5925, y: 0.8043), parentTerritory: "BUL"),
        Territory(id: "BUL_SC", name: "Bulgaria (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5675, y: 0.8143), parentTerritory: "BUL"),
        Territory(id: "SPA_NC", name: "Spain (North Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.1671, y: 0.7601), parentTerritory: "SPA"),
        Territory(id: "SPA_SC", name: "Spain (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.1671, y: 0.8101), parentTerritory: "SPA"),
        Territory(id: "STP_NC", name: "St. Petersburg (North Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.7289, y: 0.1712), parentTerritory: "STP"),
        Territory(id: "STP_SC", name: "St. Petersburg (South Coast)", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.7189, y: 0.2212), parentTerritory: "STP"),

        // Non-supply-center coastal territories
        Territory(id: "ALB", name: "Albania", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5063, y: 0.8369), parentTerritory: nil, polygon: poly("ALB")),
        Territory(id: "APU", name: "Apulia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4473, y: 0.8351), parentTerritory: nil, polygon: poly("APU")),
        Territory(id: "ARM", name: "Armenia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.864, y: 0.8245), parentTerritory: nil, polygon: poly("ARM")),
        Territory(id: "CLY", name: "Clyde", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2483, y: 0.359), parentTerritory: nil, polygon: poly("CLY")),
        Territory(id: "FIN", name: "Finland", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5548, y: 0.2362), parentTerritory: nil, polygon: poly("FIN")),
        Territory(id: "GAS", name: "Gascony", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2422, y: 0.7031), parentTerritory: nil, polygon: poly("GAS")),
        Territory(id: "LVN", name: "Livonia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5591, y: 0.446), parentTerritory: nil, polygon: poly("LVN")),
        Territory(id: "NAF", name: "North Africa", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.1749, y: 0.9577), parentTerritory: nil, polygon: poly("NAF")),
        Territory(id: "PIC", name: "Picardy", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2835, y: 0.5837), parentTerritory: nil, polygon: poly("PIC")),
        Territory(id: "PIE", name: "Piedmont", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3514, y: 0.7194), parentTerritory: nil, polygon: poly("PIE")),
        Territory(id: "PRU", name: "Prussia", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4885, y: 0.5088), parentTerritory: nil, polygon: poly("PRU")),
        Territory(id: "SYR", name: "Syria", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.8842, y: 0.9242), parentTerritory: nil, polygon: poly("SYR")),
        Territory(id: "TUS", name: "Tuscany", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3833, y: 0.7692), parentTerritory: nil, polygon: poly("TUS")),
        Territory(id: "WAL", name: "Wales", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2349, y: 0.506), parentTerritory: nil, polygon: poly("WAL")),
        Territory(id: "YOR", name: "Yorkshire", type: .coast, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2704, y: 0.4652), parentTerritory: nil, polygon: poly("YOR")),
    ]

    // MARK: - Sea Zones (19)

    static let sea: [Territory] = [
        Territory(id: "ADR", name: "Adriatic Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4497, y: 0.7927), parentTerritory: nil, polygon: poly("ADR")),
        Territory(id: "AEG", name: "Aegean Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.5832, y: 0.9149), parentTerritory: nil, polygon: poly("AEG")),
        Territory(id: "BAL", name: "Baltic Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4726, y: 0.4575), parentTerritory: nil, polygon: poly("BAL")),
        Territory(id: "BAR", name: "Barents Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.6432, y: 0.0704), parentTerritory: nil, polygon: poly("BAR")),
        Territory(id: "BLA", name: "Black Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.6987, y: 0.7453), parentTerritory: nil, polygon: poly("BLA")),
        Territory(id: "BOT", name: "Gulf of Bothnia", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.519, y: 0.3365), parentTerritory: nil, polygon: poly("BOT")),
        Territory(id: "EAS", name: "Eastern Mediterranean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.682, y: 0.9659), parentTerritory: nil, polygon: poly("EAS")),
        Territory(id: "ENG", name: "English Channel", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2261, y: 0.5568), parentTerritory: nil, polygon: poly("ENG")),
        Territory(id: "GOL", name: "Gulf of Lyon", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2932, y: 0.7977), parentTerritory: nil, polygon: poly("GOL")),
        Territory(id: "HEL", name: "Heligoland Bight", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3613, y: 0.472), parentTerritory: nil, polygon: poly("HEL")),
        Territory(id: "ION", name: "Ionian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.461, y: 0.9448), parentTerritory: nil, polygon: poly("ION")),
        Territory(id: "IRI", name: "Irish Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.1922, y: 0.496), parentTerritory: nil, polygon: poly("IRI")),
        Territory(id: "MAO", name: "Mid-Atlantic Ocean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.0805, y: 0.6912), parentTerritory: nil, polygon: poly("MAO")),
        Territory(id: "NAO", name: "North Atlantic Ocean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.1349, y: 0.2378), parentTerritory: nil, polygon: poly("NAO")),
        Territory(id: "NTH", name: "North Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.322, y: 0.4068), parentTerritory: nil, polygon: poly("NTH")),
        Territory(id: "NWG", name: "Norwegian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3575, y: 0.1256), parentTerritory: nil, polygon: poly("NWG")),
        Territory(id: "SKA", name: "Skagerrak", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.4047, y: 0.4004), parentTerritory: nil, polygon: poly("SKA")),
        Territory(id: "TYS", name: "Tyrrhenian Sea", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.3851, y: 0.8661), parentTerritory: nil, polygon: poly("TYS")),
        Territory(id: "WES", name: "Western Mediterranean", type: .sea, isSupplyCenter: false, homeCenter: nil, center: CGPoint(x: 0.2444, y: 0.884), parentTerritory: nil, polygon: poly("WES")),
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
