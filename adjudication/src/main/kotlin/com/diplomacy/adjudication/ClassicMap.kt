package com.diplomacy.adjudication

object ClassicMap {

    val definition: MapDefinition by lazy { buildMap() }

    private fun buildMap(): MapDefinition {
        val territories = buildTerritories()
        val adjacencies = buildAdjacencies()
        val startingPositions = buildStartingPositions()
        return MapDefinition(
            id = "CLASSIC",
            territories = territories.associateBy { it.id },
            adjacencies = adjacencies,
            startingPositions = startingPositions
        )
    }

    // ================================================================
    // TERRITORIES
    // ================================================================

    private fun buildTerritories(): List<Territory> {
        val territories = mutableListOf<Territory>()

        // --- Inland (14) ---
        territories += inland("BOH", "Bohemia")
        territories += inland("BUR", "Burgundy")
        territories += inland("GAL", "Galicia")
        territories += inland("RUH", "Ruhr")
        territories += inland("SIL", "Silesia")
        territories += inland("TYR", "Tyrolia")
        territories += inland("UKR", "Ukraine")
        territories += inland("BUD", "Budapest", sc = true, home = Power.AUSTRIA)
        territories += inland("MOS", "Moscow", sc = true, home = Power.RUSSIA)
        territories += inland("MUN", "Munich", sc = true, home = Power.GERMANY)
        territories += inland("PAR", "Paris", sc = true, home = Power.FRANCE)
        territories += inland("SER", "Serbia", sc = true)
        territories += inland("VIE", "Vienna", sc = true, home = Power.AUSTRIA)
        territories += inland("WAR", "Warsaw", sc = true, home = Power.RUSSIA)

        // --- Coastal: Home supply centers ---
        territories += coast("ANK", "Ankara", sc = true, home = Power.TURKEY)
        territories += coast("BER", "Berlin", sc = true, home = Power.GERMANY)
        territories += coast("BRE", "Brest", sc = true, home = Power.FRANCE)
        territories += coast("CON", "Constantinople", sc = true, home = Power.TURKEY)
        territories += coast("EDI", "Edinburgh", sc = true, home = Power.ENGLAND)
        territories += coast("KIE", "Kiel", sc = true, home = Power.GERMANY)
        territories += coast("LON", "London", sc = true, home = Power.ENGLAND)
        territories += coast("LVP", "Liverpool", sc = true, home = Power.ENGLAND)
        territories += coast("MAR", "Marseilles", sc = true, home = Power.FRANCE)
        territories += coast("NAP", "Naples", sc = true, home = Power.ITALY)
        territories += coast("ROM", "Rome", sc = true, home = Power.ITALY)
        territories += coast("SEV", "Sevastopol", sc = true, home = Power.RUSSIA)
        territories += coast("SMY", "Smyrna", sc = true, home = Power.TURKEY)
        territories += coast("TRI", "Trieste", sc = true, home = Power.AUSTRIA)
        territories += coast("VEN", "Venice", sc = true, home = Power.ITALY)

        // --- Coastal: Multi-coast parents ---
        territories += coast("BUL", "Bulgaria", sc = true, coasts = listOf("BUL_EC", "BUL_SC"))
        territories += coast("SPA", "Spain", sc = true, coasts = listOf("SPA_NC", "SPA_SC"))
        territories += coast("STP", "St. Petersburg", sc = true, home = Power.RUSSIA, coasts = listOf("STP_NC", "STP_SC"))

        // --- Coastal: Neutral supply centers ---
        territories += coast("BEL", "Belgium", sc = true)
        territories += coast("DEN", "Denmark", sc = true)
        territories += coast("GRE", "Greece", sc = true)
        territories += coast("HOL", "Holland", sc = true)
        territories += coast("NWY", "Norway", sc = true)
        territories += coast("POR", "Portugal", sc = true)
        territories += coast("RUM", "Rumania", sc = true)
        territories += coast("SWE", "Sweden", sc = true)
        territories += coast("TUN", "Tunis", sc = true)

        // --- Coastal: Non-supply center ---
        territories += coast("ALB", "Albania")
        territories += coast("APU", "Apulia")
        territories += coast("ARM", "Armenia")
        territories += coast("CLY", "Clyde")
        territories += coast("FIN", "Finland")
        territories += coast("GAS", "Gascony")
        territories += coast("LVN", "Livonia")
        territories += coast("NAF", "North Africa")
        territories += coast("PIC", "Picardy")
        territories += coast("PIE", "Piedmont")
        territories += coast("PRU", "Prussia")
        territories += coast("SYR", "Syria")
        territories += coast("TUS", "Tuscany")
        territories += coast("WAL", "Wales")
        territories += coast("YOR", "Yorkshire")

        // --- Multi-coast sub-territories ---
        territories += coast("BUL_EC", "Bulgaria (EC)", parent = "BUL")
        territories += coast("BUL_SC", "Bulgaria (SC)", parent = "BUL")
        territories += coast("SPA_NC", "Spain (NC)", parent = "SPA")
        territories += coast("SPA_SC", "Spain (SC)", parent = "SPA")
        territories += coast("STP_NC", "St. Petersburg (NC)", parent = "STP")
        territories += coast("STP_SC", "St. Petersburg (SC)", parent = "STP")

        // --- Sea zones (19) ---
        territories += sea("ADR", "Adriatic Sea")
        territories += sea("AEG", "Aegean Sea")
        territories += sea("BAL", "Baltic Sea")
        territories += sea("BAR", "Barents Sea")
        territories += sea("BLA", "Black Sea")
        territories += sea("BOT", "Gulf of Bothnia")
        territories += sea("EAS", "Eastern Mediterranean")
        territories += sea("ENG", "English Channel")
        territories += sea("GOL", "Gulf of Lyon")
        territories += sea("HEL", "Heligoland Bight")
        territories += sea("ION", "Ionian Sea")
        territories += sea("IRI", "Irish Sea")
        territories += sea("MAO", "Mid-Atlantic Ocean")
        territories += sea("NAO", "North Atlantic Ocean")
        territories += sea("NTH", "North Sea")
        territories += sea("NWG", "Norwegian Sea")
        territories += sea("SKA", "Skagerrak")
        territories += sea("TYS", "Tyrrhenian Sea")
        territories += sea("WES", "Western Mediterranean")

        return territories
    }

    private fun inland(id: String, name: String, sc: Boolean = false, home: Power? = null) =
        Territory(id, name, TerritoryType.LAND, sc, home)

    private fun coast(
        id: String, name: String, sc: Boolean = false, home: Power? = null,
        coasts: List<String> = emptyList(), parent: String? = null
    ) = Territory(id, name, TerritoryType.COAST, sc, home, parent, coasts)

    private fun sea(id: String, name: String) =
        Territory(id, name, TerritoryType.SEA)

    // ================================================================
    // ADJACENCIES
    // ================================================================

    private fun buildAdjacencies(): Map<String, List<Adjacency>> {
        val raw = mutableListOf<Triple<String, String, Set<UnitType>>>()
        val A = setOf(UnitType.ARMY)
        val F = setOf(UnitType.FLEET)
        val AF = setOf(UnitType.ARMY, UnitType.FLEET)

        // === INLAND-INLAND and INLAND-COASTAL (army only) ===
        raw += Triple("BOH", "MUN", A)
        raw += Triple("BOH", "SIL", A)
        raw += Triple("BOH", "GAL", A)
        raw += Triple("BOH", "VIE", A)
        raw += Triple("BOH", "TYR", A)
        raw += Triple("BUD", "VIE", A)
        raw += Triple("BUD", "TRI", A)
        raw += Triple("BUD", "SER", A)
        raw += Triple("BUD", "RUM", A)
        raw += Triple("BUD", "GAL", A)
        raw += Triple("BUR", "PAR", A)
        raw += Triple("BUR", "PIC", A)
        raw += Triple("BUR", "BEL", A)
        raw += Triple("BUR", "RUH", A)
        raw += Triple("BUR", "MUN", A)
        raw += Triple("BUR", "MAR", A)
        raw += Triple("BUR", "GAS", A)
        raw += Triple("GAL", "VIE", A)
        raw += Triple("GAL", "WAR", A)
        raw += Triple("GAL", "UKR", A)
        raw += Triple("GAL", "RUM", A)
        raw += Triple("GAL", "SIL", A)
        raw += Triple("MOS", "UKR", A)
        raw += Triple("MOS", "WAR", A)
        raw += Triple("MOS", "LVN", A)
        raw += Triple("MOS", "SEV", A)
        raw += Triple("MOS", "STP", A)
        raw += Triple("MOS", "FIN", A)
        raw += Triple("MUN", "RUH", A)
        raw += Triple("MUN", "KIE", A)
        raw += Triple("MUN", "BER", A)
        raw += Triple("MUN", "SIL", A)
        raw += Triple("MUN", "TYR", A)
        raw += Triple("PAR", "PIC", A)
        raw += Triple("PAR", "BRE", A)
        raw += Triple("PAR", "GAS", A)
        raw += Triple("RUH", "BEL", A)
        raw += Triple("RUH", "HOL", A)
        raw += Triple("RUH", "KIE", A)
        raw += Triple("SER", "TRI", A)
        raw += Triple("SER", "ALB", A)
        raw += Triple("SER", "GRE", A)
        raw += Triple("SER", "BUL", A)
        raw += Triple("SER", "RUM", A)
        raw += Triple("SIL", "WAR", A)
        raw += Triple("SIL", "PRU", A)
        raw += Triple("SIL", "BER", A)
        raw += Triple("TYR", "VIE", A)
        raw += Triple("TYR", "TRI", A)
        raw += Triple("TYR", "VEN", A)
        raw += Triple("TYR", "PIE", A)
        raw += Triple("UKR", "WAR", A)
        raw += Triple("UKR", "SEV", A)
        raw += Triple("UKR", "RUM", A)
        raw += Triple("WAR", "PRU", A)
        raw += Triple("WAR", "LVN", A)

        // === COASTAL-COASTAL (army+fleet where coast touches) ===
        raw += Triple("ALB", "TRI", AF)
        raw += Triple("ALB", "GRE", AF)
        raw += Triple("ALB", "ION", F)
        raw += Triple("ALB", "ADR", F)
        raw += Triple("ANK", "CON", AF)
        raw += Triple("ANK", "ARM", AF)
        raw += Triple("ANK", "BLA", F)
        raw += Triple("APU", "VEN", AF)
        raw += Triple("APU", "ROM", A)
        raw += Triple("APU", "NAP", AF)
        raw += Triple("APU", "ADR", F)
        raw += Triple("APU", "ION", F)
        raw += Triple("ARM", "SEV", AF)
        raw += Triple("ARM", "SYR", AF)
        raw += Triple("ARM", "BLA", F)
        raw += Triple("BEL", "HOL", AF)
        raw += Triple("BEL", "PIC", AF)
        raw += Triple("BEL", "ENG", F)
        raw += Triple("BEL", "NTH", F)
        raw += Triple("BER", "PRU", AF)
        raw += Triple("BER", "KIE", AF)
        raw += Triple("BER", "BAL", F)
        raw += Triple("BRE", "PIC", AF)
        raw += Triple("BRE", "GAS", AF)
        raw += Triple("BRE", "ENG", F)
        raw += Triple("BRE", "MAO", F)
        raw += Triple("CLY", "EDI", AF)
        raw += Triple("CLY", "LVP", AF)
        raw += Triple("CLY", "NAO", F)
        raw += Triple("CLY", "NWG", F)
        raw += Triple("CON", "SMY", AF)
        raw += Triple("CON", "BUL", A)
        raw += Triple("CON", "BUL_SC", F)
        raw += Triple("CON", "BUL_EC", F)
        raw += Triple("CON", "AEG", F)
        raw += Triple("CON", "BLA", F)
        raw += Triple("DEN", "KIE", AF)
        raw += Triple("DEN", "SWE", AF)
        raw += Triple("DEN", "NTH", F)
        raw += Triple("DEN", "SKA", F)
        raw += Triple("DEN", "BAL", F)
        raw += Triple("DEN", "HEL", F)
        raw += Triple("EDI", "YOR", A)
        raw += Triple("EDI", "LVP", A)
        raw += Triple("EDI", "NTH", F)
        raw += Triple("EDI", "NWG", F)
        raw += Triple("FIN", "NWY", A)
        raw += Triple("FIN", "SWE", AF)
        raw += Triple("FIN", "STP", A)
        raw += Triple("FIN", "STP_SC", F)
        raw += Triple("FIN", "BOT", F)
        raw += Triple("GAS", "MAR", A)
        raw += Triple("GAS", "SPA", A)
        raw += Triple("GAS", "SPA_NC", F)
        raw += Triple("GAS", "MAO", F)
        raw += Triple("GRE", "BUL", A)
        raw += Triple("GRE", "BUL_SC", F)
        raw += Triple("GRE", "ION", F)
        raw += Triple("GRE", "AEG", F)
        raw += Triple("HOL", "HEL", F)
        raw += Triple("HOL", "NTH", F)
        raw += Triple("KIE", "HOL", AF)
        raw += Triple("KIE", "HEL", F)
        raw += Triple("KIE", "BAL", F)
        raw += Triple("LON", "YOR", A)
        raw += Triple("LON", "WAL", A)
        raw += Triple("LON", "ENG", F)
        raw += Triple("LON", "NTH", F)
        raw += Triple("LVN", "STP", A)
        raw += Triple("LVN", "STP_SC", F)
        raw += Triple("LVN", "PRU", AF)
        raw += Triple("LVN", "BAL", F)
        raw += Triple("LVN", "BOT", F)
        raw += Triple("LVP", "YOR", A)
        raw += Triple("LVP", "WAL", AF)
        raw += Triple("LVP", "IRI", F)
        raw += Triple("LVP", "NAO", F)
        raw += Triple("MAR", "PIE", A)
        raw += Triple("MAR", "SPA", A)
        raw += Triple("MAR", "SPA_SC", F)
        raw += Triple("MAR", "GOL", F)
        raw += Triple("NAF", "TUN", AF)
        raw += Triple("NAF", "MAO", F)
        raw += Triple("NAF", "WES", F)
        raw += Triple("NAP", "ROM", AF)
        raw += Triple("NAP", "ION", F)
        raw += Triple("NAP", "TYS", F)
        raw += Triple("NWY", "SWE", AF)
        raw += Triple("NWY", "STP", A)
        raw += Triple("NWY", "STP_NC", F)
        raw += Triple("NWY", "NTH", F)
        raw += Triple("NWY", "NWG", F)
        raw += Triple("NWY", "SKA", F)
        raw += Triple("NWY", "BAR", F)
        raw += Triple("PIC", "ENG", F)
        raw += Triple("PIE", "VEN", A)
        raw += Triple("PIE", "TUS", AF)
        raw += Triple("PIE", "GOL", F)
        raw += Triple("POR", "SPA", A)
        raw += Triple("POR", "SPA_NC", F)
        raw += Triple("POR", "SPA_SC", F)
        raw += Triple("POR", "MAO", F)
        raw += Triple("PRU", "BAL", F)
        raw += Triple("ROM", "VEN", A)
        raw += Triple("ROM", "TUS", AF)
        raw += Triple("ROM", "TYS", F)
        raw += Triple("RUM", "BUL", A)
        raw += Triple("RUM", "BUL_EC", F)
        raw += Triple("RUM", "SEV", AF)
        raw += Triple("RUM", "BLA", F)
        raw += Triple("SEV", "BLA", F)
        raw += Triple("SMY", "SYR", AF)
        raw += Triple("SMY", "ARM", A)
        raw += Triple("SMY", "AEG", F)
        raw += Triple("SMY", "EAS", F)
        raw += Triple("SPA_NC", "MAO", F)
        raw += Triple("SPA_SC", "MAO", F)
        raw += Triple("SPA_SC", "GOL", F)
        raw += Triple("SPA_SC", "WES", F)
        raw += Triple("STP_NC", "BAR", F)
        raw += Triple("STP_SC", "BOT", F)
        raw += Triple("SWE", "SKA", F)
        raw += Triple("SWE", "BAL", F)
        raw += Triple("SWE", "BOT", F)
        raw += Triple("SYR", "EAS", F)
        raw += Triple("TRI", "VEN", AF)
        raw += Triple("TRI", "ADR", F)
        raw += Triple("TUN", "ION", F)
        raw += Triple("TUN", "TYS", F)
        raw += Triple("TUN", "WES", F)
        raw += Triple("TUS", "VEN", A)
        raw += Triple("TUS", "GOL", F)
        raw += Triple("TUS", "TYS", F)
        raw += Triple("WAL", "YOR", A)
        raw += Triple("WAL", "ENG", F)
        raw += Triple("WAL", "IRI", F)

        // === SEA-SEA ===
        raw += Triple("ADR", "ION", F)
        raw += Triple("AEG", "ION", F)
        raw += Triple("AEG", "EAS", F)
        raw += Triple("AEG", "BLA", F)
        raw += Triple("BAR", "NWG", F)
        raw += Triple("BOT", "BAL", F)
        raw += Triple("EAS", "ION", F)
        raw += Triple("ENG", "IRI", F)
        raw += Triple("ENG", "MAO", F)
        raw += Triple("ENG", "NTH", F)
        raw += Triple("GOL", "TYS", F)
        raw += Triple("GOL", "WES", F)
        raw += Triple("HEL", "NTH", F)
        raw += Triple("ION", "TYS", F)
        raw += Triple("IRI", "MAO", F)
        raw += Triple("IRI", "NAO", F)
        raw += Triple("MAO", "NAO", F)
        raw += Triple("MAO", "WES", F)
        raw += Triple("NAO", "NWG", F)
        raw += Triple("NTH", "NWG", F)
        raw += Triple("NTH", "SKA", F)
        raw += Triple("SKA", "BAL", F)
        raw += Triple("TYS", "WES", F)

        // Mirror all adjacencies to make bidirectional
        val result = mutableMapOf<String, MutableList<Adjacency>>()
        for ((from, to, types) in raw) {
            result.getOrPut(from) { mutableListOf() }.add(Adjacency(to, types))
            result.getOrPut(to) { mutableListOf() }.add(Adjacency(from, types))
        }
        return result
    }

    // ================================================================
    // STARTING POSITIONS (Spring 1901)
    // ================================================================

    private fun buildStartingPositions(): Map<Power, List<StartingUnit>> = mapOf(
        Power.AUSTRIA to listOf(
            StartingUnit(Power.AUSTRIA, "VIE", UnitType.ARMY),
            StartingUnit(Power.AUSTRIA, "BUD", UnitType.ARMY),
            StartingUnit(Power.AUSTRIA, "TRI", UnitType.FLEET)
        ),
        Power.ENGLAND to listOf(
            StartingUnit(Power.ENGLAND, "LON", UnitType.FLEET),
            StartingUnit(Power.ENGLAND, "EDI", UnitType.FLEET),
            StartingUnit(Power.ENGLAND, "LVP", UnitType.ARMY)
        ),
        Power.FRANCE to listOf(
            StartingUnit(Power.FRANCE, "PAR", UnitType.ARMY),
            StartingUnit(Power.FRANCE, "MAR", UnitType.ARMY),
            StartingUnit(Power.FRANCE, "BRE", UnitType.FLEET)
        ),
        Power.GERMANY to listOf(
            StartingUnit(Power.GERMANY, "BER", UnitType.ARMY),
            StartingUnit(Power.GERMANY, "MUN", UnitType.ARMY),
            StartingUnit(Power.GERMANY, "KIE", UnitType.FLEET)
        ),
        Power.ITALY to listOf(
            StartingUnit(Power.ITALY, "ROM", UnitType.ARMY),
            StartingUnit(Power.ITALY, "VEN", UnitType.ARMY),
            StartingUnit(Power.ITALY, "NAP", UnitType.FLEET)
        ),
        Power.RUSSIA to listOf(
            StartingUnit(Power.RUSSIA, "MOS", UnitType.ARMY),
            StartingUnit(Power.RUSSIA, "WAR", UnitType.ARMY),
            StartingUnit(Power.RUSSIA, "SEV", UnitType.FLEET),
            StartingUnit(Power.RUSSIA, "STP_SC", UnitType.FLEET)
        ),
        Power.TURKEY to listOf(
            StartingUnit(Power.TURKEY, "CON", UnitType.ARMY),
            StartingUnit(Power.TURKEY, "SMY", UnitType.ARMY),
            StartingUnit(Power.TURKEY, "ANK", UnitType.FLEET)
        )
    )
}
