package com.diplomacy.game

import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("game_players")
data class GamePlayer(
    val gameId: UUID,
    val playerId: UUID,
    val power: String,
    val isEliminated: Boolean = false,
    val isAiControlled: Boolean = false,
    val consecutiveMisses: Int = 0,
    val ordersSubmitted: Boolean = false,
    val supplyCenterCount: Int = 3,
    val prevSupplyCenterCount: Int = 3,
    val unreadMessageCount: Int = 0,
    val joinedAt: Instant = Instant.now()
)
