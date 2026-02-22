package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("orders")
data class GameOrderEntity(
    @Id val id: UUID? = null,
    @Column("game_id") val gameId: UUID,
    @Column("player_id") val playerId: UUID,
    @Column("power") val power: String,
    @Column("phase") val phase: String,
    @Column("season") val season: String,
    @Column("year") val year: Int,
    @Column("orders") val orders: String, // JSONB stored as String
    @Column("is_default") val isDefault: Boolean = false,
    @Column("validation_results") val validationResults: String? = null,
    @Column("submitted_at") val submittedAt: Instant = Instant.now()
)
