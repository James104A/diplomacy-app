package com.diplomacy.game

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Mono
import java.util.UUID

interface GameStateRepository : ReactiveCrudRepository<GameStateEntity, UUID> {
    @Query("SELECT * FROM game_states WHERE game_id = :gameId ORDER BY created_at DESC LIMIT 1")
    fun findLatestByGameId(gameId: UUID): Mono<GameStateEntity>

    @Query("SELECT * FROM game_states WHERE game_id = :gameId AND is_initial = true LIMIT 1")
    fun findInitialByGameId(gameId: UUID): Mono<GameStateEntity>
}
