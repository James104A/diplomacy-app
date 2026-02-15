package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("orders")
data class GameOrderEntity(
    @Id val id: UUID? = null,
    val gameId: UUID,
    val playerId: UUID,
    val power: String,
    val phase: String,
    val season: String,
    val year: Int,
    @Column("orders") val orders: String, // JSONB stored as String
    val isDefault: Boolean = false,
    @Column("validation_results") val validationResults: String? = null,
    val submittedAt: Instant = Instant.now()
)
