package com.diplomacy.player

import com.diplomacy.game.GameService
import com.diplomacy.game.GameSummary
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
@RequestMapping("/v1/players")
class PlayerController(
    private val playerService: PlayerService,
    private val gameService: GameService
) {

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

    // E4-S7: Dashboard — list player's games
    @GetMapping("/me/games")
    fun getMyGames(@AuthenticationPrincipal playerId: UUID): Flux<GameSummary> {
        return gameService.getPlayerGames(playerId)
    }
}
