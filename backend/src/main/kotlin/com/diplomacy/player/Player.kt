package com.diplomacy.player

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

@Table("players")
data class Player(
    @Id val id: UUID? = null,
    val displayName: String,
    val email: String,
    val passwordHash: String? = null,
    val authProvider: String,
    val avatarUrl: String? = null,

    val eloClassic: Int = 1000,
    val elo1v1: Int = 1000,
    val eloVariant: Int = 1000,
    val peakEloClassic: Int = 1000,
    val rankTier: String = "UNRANKED",
    val placementRemaining: Int = 5,

    val reliabilityScore: BigDecimal = BigDecimal("100.00"),
    val totalPhases: Int = 0,
    val missedDeadlines: Int = 0,
    val abandonedGames: Int = 0,
    val isRestricted: Boolean = false,

    val gamesPlayed: Int = 0,
    val gamesWon: Int = 0,
    val gamesDrawn: Int = 0,

    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
    val deletedAt: Instant? = null
)
