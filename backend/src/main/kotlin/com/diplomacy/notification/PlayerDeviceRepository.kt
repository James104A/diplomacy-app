package com.diplomacy.notification

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

interface PlayerDeviceRepository : ReactiveCrudRepository<PlayerDevice, UUID> {
    fun findByPlayerIdAndIsActive(playerId: UUID, isActive: Boolean = true): Flux<PlayerDevice>

    fun findByPlayerIdAndDeviceId(playerId: UUID, deviceId: String): Mono<PlayerDevice>

    @Query("UPDATE player_devices SET is_active = false WHERE player_id = :playerId AND device_id = :deviceId")
    fun deactivateDevice(playerId: UUID, deviceId: String): Mono<Void>

    @Query("UPDATE player_devices SET last_seen_at = NOW() WHERE player_id = :playerId AND device_id = :deviceId")
    fun updateLastSeen(playerId: UUID, deviceId: String): Mono<Void>
}
