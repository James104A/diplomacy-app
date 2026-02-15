package com.diplomacy.game

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

interface GameRepository : ReactiveCrudRepository<Game, UUID> {
    fun findByInviteCode(inviteCode: String): Mono<Game>
    fun findByStatusAndPhaseDeadlineBefore(status: String, deadline: Instant): Flux<Game>
    fun findByCreatorId(creatorId: UUID): Flux<Game>
}
