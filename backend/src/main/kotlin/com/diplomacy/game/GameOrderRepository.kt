package com.diplomacy.game

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

interface GameOrderRepository : ReactiveCrudRepository<GameOrderEntity, UUID> {
    fun findByGameIdAndSeasonAndYearAndPhase(
        gameId: UUID, season: String, year: Int, phase: String
    ): Flux<GameOrderEntity>

    @Query("""
        SELECT * FROM orders
        WHERE game_id = :gameId AND player_id = :playerId
          AND season = :season AND year = :year AND phase = :phase
        LIMIT 1
    """)
    fun findByPlayerAndPhase(
        gameId: UUID, playerId: UUID, season: String, year: Int, phase: String
    ): Mono<GameOrderEntity>

    @Query("""
        DELETE FROM orders
        WHERE game_id = :gameId AND player_id = :playerId
          AND season = :season AND year = :year AND phase = :phase
    """)
    fun deleteByPlayerAndPhase(
        gameId: UUID, playerId: UUID, season: String, year: Int, phase: String
    ): Mono<Void>
}
