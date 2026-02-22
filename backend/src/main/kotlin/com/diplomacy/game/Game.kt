package com.diplomacy.game

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("games")
data class Game(
    @Id val id: UUID? = null,
    @Column("name") val name: String,
    @Column("status") val status: String = "WAITING_FOR_PLAYERS",
    @Column("creator_id") val creatorId: UUID,
    @Column("map_id") val mapId: String = "CLASSIC",

    @Column("phase_length") val phaseLength: Long = 86400, // seconds
    @Column("press_rules") val pressRules: String = "FULL_PRESS",
    @Column("scoring_system") val scoringSystem: String = "DRAW_SIZE",
    @Column("min_reliability") val minReliability: Int = 70,
    @Column("is_ranked") val isRanked: Boolean = true,
    @Column("visibility") val visibility: String = "PUBLIC",
    @Column("invite_code") val inviteCode: String? = null,
    @Column("read_receipts") val readReceipts: Boolean = false,
    @Column("anonymous_countries") val anonymousCountries: Boolean = false,

    @Column("current_phase") val currentPhase: String = "ORDER_SUBMISSION",
    @Column("current_season") val currentSeason: String = "SPRING",
    @Column("current_year") val currentYear: Int = 1901,
    @Column("phase_deadline") val phaseDeadline: Instant? = null,
    @Column("all_orders_submitted") val allOrdersSubmitted: Boolean = false,

    @Column("result") val result: String? = null,
    @Column("winner_power") val winnerPower: String? = null,
    @Column("winner_player_id") val winnerPlayerId: UUID? = null,

    @Column("player_count") val playerCount: Int = 0,

    @Column("created_at") val createdAt: Instant = Instant.now(),
    @Column("started_at") val startedAt: Instant? = null,
    @Column("completed_at") val completedAt: Instant? = null
)
