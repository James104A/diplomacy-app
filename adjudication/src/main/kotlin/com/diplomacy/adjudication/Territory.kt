package com.diplomacy.adjudication

data class Territory(
    val id: String,
    val name: String,
    val type: TerritoryType,
    val isSupplyCenter: Boolean = false,
    val homeCenter: Power? = null,
    val parentTerritory: String? = null,
    val coasts: List<String> = emptyList()
)

enum class TerritoryType {
    LAND, SEA, COAST
}

data class Adjacency(
    val targetId: String,
    val unitTypes: Set<UnitType>
)
