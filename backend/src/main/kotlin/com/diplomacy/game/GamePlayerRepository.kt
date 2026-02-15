package com.diplomacy.game

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

interface GamePlayerRepository : ReactiveCrudRepository<GamePlayer, UUID> {
    fun findByGameId(gameId: UUID): Flux<GamePlayer>
    fun findByPlayerId(playerId: UUID): Flux<GamePlayer>
    fun findByGameIdAndPlayerId(gameId: UUID, playerId: UUID): Mono<GamePlayer>

    @Query("SELECT COUNT(*) FROM game_players WHERE game_id = :gameId AND orders_submitted = true AND is_eliminated = false")
    fun countSubmittedOrders(gameId: UUID): Mono<Long>

    @Query("SELECT COUNT(*) FROM game_players WHERE game_id = :gameId AND is_eliminated = false")
    fun countActivePlayers(gameId: UUID): Mono<Long>
}
