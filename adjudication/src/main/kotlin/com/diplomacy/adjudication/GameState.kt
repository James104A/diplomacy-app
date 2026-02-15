package com.diplomacy.adjudication

data class GameState(
    val phase: Phase,
    val year: Int,
    val season: Season,
    val units: List<MapUnit>,
    val supplyCenterOwnership: Map<String, Power>,
    val dislodgedUnits: List<DislodgedUnit> = emptyList(),
    val standoffTerritories: Set<String> = emptySet()
)

data class MapUnit(
    val power: Power,
    val type: UnitType,
    val territoryId: String
)

data class DislodgedUnit(
    val unit: MapUnit,
    val attackedFrom: String
)
