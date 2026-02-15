package com.diplomacy.messaging

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import java.util.UUID

interface ConversationRepository : ReactiveCrudRepository<Conversation, UUID> {
    fun findByGameId(gameId: UUID): Flux<Conversation>
}
