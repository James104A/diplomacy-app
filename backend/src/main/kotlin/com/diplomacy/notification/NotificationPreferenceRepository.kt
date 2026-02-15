package com.diplomacy.notification

import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Mono
import java.util.UUID

interface NotificationPreferenceRepository : ReactiveCrudRepository<NotificationPreference, UUID> {
    fun findByPlayerId(playerId: UUID): Mono<NotificationPreference>
}
