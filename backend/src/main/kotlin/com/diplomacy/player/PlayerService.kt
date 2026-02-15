package com.diplomacy.player

import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

@Service
class PlayerService(private val playerRepository: PlayerRepository) {

    fun getProfile(playerId: UUID): Mono<PlayerProfile> {
        return playerRepository.findById(playerId)
            .filter { it.deletedAt == null }
            .map { it.toProfile() }
            .switchIfEmpty(Mono.error(ResponseStatusException(HttpStatus.NOT_FOUND, "Player not found")))
    }

    fun updateProfile(playerId: UUID, request: UpdateProfileRequest): Mono<PlayerProfile> {
        return playerRepository.findById(playerId)
            .filter { it.deletedAt == null }
            .switchIfEmpty(Mono.error(ResponseStatusException(HttpStatus.NOT_FOUND, "Player not found")))
            .flatMap { player ->
                val updated = player.copy(
                    displayName = request.displayName ?: player.displayName,
                    avatarUrl = request.avatarUrl ?: player.avatarUrl,
                    updatedAt = Instant.now()
                )
                playerRepository.save(updated)
            }
            .map { it.toProfile() }
    }

    fun deleteAccount(playerId: UUID): Mono<Void> {
        return playerRepository.findById(playerId)
            .filter { it.deletedAt == null }
            .switchIfEmpty(Mono.error(ResponseStatusException(HttpStatus.NOT_FOUND, "Player not found")))
            .flatMap { player ->
                playerRepository.save(player.copy(deletedAt = Instant.now(), updatedAt = Instant.now()))
            }
            .then()
    }
}
