package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Duration
import java.time.Instant
import java.util.UUID

@Table("games")
data class Game(
    @Id val id: UUID? = null,
    val name: String,
    val status: String = "WAITING_FOR_PLAYERS",
    val creatorId: UUID,
    val mapId: String = "CLASSIC",

    val phaseLength: Duration = Duration.ofHours(24),
    val pressRules: String = "FULL_PRESS",
    val scoringSystem: String = "DRAW_SIZE",
    val minReliability: Int = 70,
    val isRanked: Boolean = true,
    val visibility: String = "PUBLIC",
    val inviteCode: String? = null,
    val readReceipts: Boolean = false,
    val anonymousCountries: Boolean = false,

    val currentPhase: String = "ORDER_SUBMISSION",
    val currentSeason: String = "SPRING",
    val currentYear: Int = 1901,
    val phaseDeadline: Instant? = null,
    val allOrdersSubmitted: Boolean = false,

    val result: String? = null,
    val winnerPower: String? = null,
    val winnerPlayerId: UUID? = null,

    val playerCount: Int = 0,

    val createdAt: Instant = Instant.now(),
    val startedAt: Instant? = null,
    val completedAt: Instant? = null
)
