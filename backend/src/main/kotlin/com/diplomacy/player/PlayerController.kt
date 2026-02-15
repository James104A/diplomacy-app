package com.diplomacy.player

import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
@RequestMapping("/v1/players")
class PlayerController(private val playerService: PlayerService) {

    @GetMapping("/me")
    fun getMyProfile(@AuthenticationPrincipal playerId: UUID): Mono<PlayerProfile> {
        return playerService.getProfile(playerId)
    }

    @PatchMapping("/me")
    fun updateMyProfile(
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: UpdateProfileRequest
    ): Mono<PlayerProfile> {
        return playerService.updateProfile(playerId, request)
    }

    @DeleteMapping("/me")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteMyAccount(@AuthenticationPrincipal playerId: UUID): Mono<Void> {
        return playerService.deleteAccount(playerId)
    }
}
