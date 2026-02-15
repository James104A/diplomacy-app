package com.diplomacy.adjudication

data class MapDefinition(
    val id: String,
    val territories: Map<String, Territory>,
    val adjacencies: Map<String, List<Adjacency>>,
    val startingPositions: Map<Power, List<StartingUnit>>
) {
    fun territory(id: String): Territory =
        territories[id] ?: throw IllegalArgumentException("Unknown territory: $id")

    fun adjacenciesOf(territoryId: String): List<Adjacency> =
        adjacencies[territoryId] ?: emptyList()

    fun isAdjacent(from: String, to: String, unitType: UnitType): Boolean {
        // Check direct adjacency
        if (adjacenciesOf(from).any { it.targetId == to && unitType in it.unitTypes }) return true
        // For armies: check parent territory adjacency (multi-coast)
        if (unitType == UnitType.ARMY) {
            val fromParent = territories[from]?.parentTerritory
            val toParent = territories[to]?.parentTerritory
            val effectiveFrom = fromParent ?: from
            val effectiveTo = toParent ?: to
            if (effectiveFrom != from || effectiveTo != to) {
                return adjacenciesOf(effectiveFrom).any { it.targetId == effectiveTo && unitType in it.unitTypes }
            }
        }
        return false
    }

    fun getReachableCoasts(from: String, parentTerritory: String): List<String> {
        val coasts = territories[parentTerritory]?.coasts ?: return emptyList()
        return coasts.filter { coastId ->
            adjacenciesOf(from).any { it.targetId == coastId && UnitType.FLEET in it.unitTypes }
        }
    }
}

data class StartingUnit(
    val power: Power,
    val territoryId: String,
    val unitType: UnitType
)
