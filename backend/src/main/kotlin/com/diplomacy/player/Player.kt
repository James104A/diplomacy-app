package com.diplomacy.player

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

@Table("players")
data class Player(
    @Id val id: UUID? = null,
    @Column("display_name") val displayName: String,
    @Column("email") val email: String,
    @Column("password_hash") val passwordHash: String? = null,
    @Column("auth_provider") val authProvider: String,
    @Column("avatar_url") val avatarUrl: String? = null,

    @Column("elo_classic") val eloClassic: Int = 1000,
    @Column("elo_1v1") val elo1v1: Int = 1000,
    @Column("elo_variant") val eloVariant: Int = 1000,
    @Column("peak_elo_classic") val peakEloClassic: Int = 1000,
    @Column("rank_tier") val rankTier: String = "UNRANKED",
    @Column("placement_remaining") val placementRemaining: Int = 5,

    @Column("reliability_score") val reliabilityScore: BigDecimal = BigDecimal("100.00"),
    @Column("total_phases") val totalPhases: Int = 0,
    @Column("missed_deadlines") val missedDeadlines: Int = 0,
    @Column("abandoned_games") val abandonedGames: Int = 0,
    @Column("is_restricted") val isRestricted: Boolean = false,

    @Column("games_played") val gamesPlayed: Int = 0,
    @Column("games_won") val gamesWon: Int = 0,
    @Column("games_drawn") val gamesDrawn: Int = 0,

    @Column("created_at") val createdAt: Instant = Instant.now(),
    @Column("updated_at") val updatedAt: Instant = Instant.now(),
    @Column("deleted_at") val deletedAt: Instant? = null
)
