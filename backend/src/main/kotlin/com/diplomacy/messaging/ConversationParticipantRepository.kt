package com.diplomacy.messaging

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

interface ConversationParticipantRepository : ReactiveCrudRepository<ConversationParticipant, UUID> {
    fun findByConversationId(conversationId: UUID): Flux<ConversationParticipant>

    fun findByConversationIdAndPlayerId(conversationId: UUID, playerId: UUID): Mono<ConversationParticipant>

    @Query("SELECT * FROM conversation_participants WHERE player_id = :playerId AND conversation_id IN (SELECT id FROM conversations WHERE game_id = :gameId)")
    fun findByPlayerIdAndGameId(playerId: UUID, gameId: UUID): Flux<ConversationParticipant>

    @Query("SELECT * FROM conversation_participants WHERE power = :power AND conversation_id IN (SELECT id FROM conversations WHERE game_id = :gameId)")
    fun findByPowerAndGameId(power: String, gameId: UUID): Flux<ConversationParticipant>
}
