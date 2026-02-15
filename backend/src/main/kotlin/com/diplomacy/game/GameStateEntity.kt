package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("game_states")
data class GameStateEntity(
    @Id val id: UUID? = null,
    val gameId: UUID,
    val phase: String,
    val season: String,
    val year: Int,
    val phaseLabel: String,
    @Column("units") val units: String, // JSONB stored as String
    @Column("supply_centers") val supplyCenters: String, // JSONB stored as String
    @Column("dislodged_units") val dislodgedUnits: String? = null,
    @Column("standoff_territories") val standoffTerritories: String? = null,
    val isInitial: Boolean = false,
    val createdAt: Instant = Instant.now()
)
