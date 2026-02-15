package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("resolved_phases")
data class ResolvedPhaseEntity(
    @Id val id: UUID? = null,
    val gameId: UUID,
    val beforeStateId: UUID,
    val afterStateId: UUID,
    val phase: String,
    val season: String,
    val year: Int,
    val phaseLabel: String,
    @Column("all_orders") val allOrders: String, // JSONB
    @Column("resolved_orders") val resolvedOrders: String, // JSONB
    @Column("supply_center_changes") val supplyCenterChanges: String? = null,
    val eliminations: Array<String>? = null,
    @Column("resolution_steps") val resolutionSteps: String? = null,
    val resolvedAt: Instant = Instant.now()
)
