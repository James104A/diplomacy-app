package com.diplomacy.messaging

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Mono
import java.util.UUID

interface ProposalRepository : ReactiveCrudRepository<Proposal, UUID> {
    fun findByMessageId(messageId: UUID): Mono<Proposal>
}
