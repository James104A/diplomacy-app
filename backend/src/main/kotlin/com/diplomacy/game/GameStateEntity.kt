package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("game_states")
data class GameStateEntity(
    @Id val id: UUID? = null,
    @Column("game_id") val gameId: UUID,
    @Column("phase") val phase: String,
    @Column("season") val season: String,
    @Column("year") val year: Int,
    @Column("phase_label") val phaseLabel: String,
    @Column("units") val units: String, // JSONB stored as String
    @Column("supply_centers") val supplyCenters: String, // JSONB stored as String
    @Column("dislodged_units") val dislodgedUnits: String? = null,
    @Column("standoff_territories") val standoffTerritories: String? = null,
    @Column("is_initial") val isInitial: Boolean = false,
    @Column("created_at") val createdAt: Instant = Instant.now()
)
