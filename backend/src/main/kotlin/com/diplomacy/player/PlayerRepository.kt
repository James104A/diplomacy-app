package com.diplomacy.player

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Mono
import java.util.UUID

interface PlayerRepository : ReactiveCrudRepository<Player, UUID> {
    fun findByEmail(email: String): Mono<Player>
    fun findByDisplayName(displayName: String): Mono<Player>
}
