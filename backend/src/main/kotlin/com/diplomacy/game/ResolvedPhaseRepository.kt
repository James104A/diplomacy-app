package com.diplomacy.game

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import java.util.UUID

interface ResolvedPhaseRepository : ReactiveCrudRepository<ResolvedPhaseEntity, UUID> {
    fun findByGameIdOrderByResolvedAtDesc(gameId: UUID): Flux<ResolvedPhaseEntity>
}
