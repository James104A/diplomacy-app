package com.diplomacy.game

import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("game_players")
data class GamePlayer(
    @Column("game_id") val gameId: UUID,
    @Column("player_id") val playerId: UUID,
    @Column("power") val power: String,
    @Column("is_eliminated") val isEliminated: Boolean = false,
    @Column("is_ai_controlled") val isAiControlled: Boolean = false,
    @Column("consecutive_misses") val consecutiveMisses: Int = 0,
    @Column("orders_submitted") val ordersSubmitted: Boolean = false,
    @Column("supply_center_count") val supplyCenterCount: Int = 3,
    @Column("prev_supply_center_count") val prevSupplyCenterCount: Int = 3,
    @Column("unread_message_count") val unreadMessageCount: Int = 0,
    @Column("joined_at") val joinedAt: Instant = Instant.now()
)
