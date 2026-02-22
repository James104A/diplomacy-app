package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("resolved_phases")
data class ResolvedPhaseEntity(
    @Id val id: UUID? = null,
    @Column("game_id") val gameId: UUID,
    @Column("before_state_id") val beforeStateId: UUID,
    @Column("after_state_id") val afterStateId: UUID,
    @Column("phase") val phase: String,
    @Column("season") val season: String,
    @Column("year") val year: Int,
    @Column("phase_label") val phaseLabel: String,
    @Column("all_orders") val allOrders: String, // JSONB
    @Column("resolved_orders") val resolvedOrders: String, // JSONB
    @Column("supply_center_changes") val supplyCenterChanges: String? = null,
    @Column("eliminations") val eliminations: Array<String>? = null,
    @Column("resolution_steps") val resolutionSteps: String? = null,
    @Column("resolved_at") val resolvedAt: Instant = Instant.now()
)
