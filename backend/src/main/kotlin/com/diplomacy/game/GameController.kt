package com.diplomacy.game

import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
@RequestMapping("/v1/games")
class GameController(private val gameService: GameService) {

    // E4-S1: Create game
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createGame(
        @Valid @RequestBody request: CreateGameRequest,
        @AuthenticationPrincipal playerId: UUID
    ): Mono<GameResponse> {
        return gameService.createGame(request, playerId)
    }

    // E4-S2: Join game by ID (public games)
    @PostMapping("/{gameId}/join")
    fun joinGame(
        @PathVariable gameId: UUID,
        @AuthenticationPrincipal playerId: UUID
    ): Mono<GameResponse> {
        return gameService.joinGameById(gameId, playerId)
    }

    // E4-S2: Join game by invite code (private games)
    @PostMapping("/join/{inviteCode}")
    fun joinGameByInviteCode(
        @PathVariable inviteCode: String,
        @AuthenticationPrincipal playerId: UUID
    ): Mono<GameResponse> {
        return gameService.joinGameByInviteCode(inviteCode, playerId)
    }

    // E4-S3: Get full game state
    @GetMapping("/{gameId}")
    fun getGame(@PathVariable gameId: UUID): Mono<GameStateResponse> {
        return gameService.getGame(gameId)
    }

    // E4-S4: Submit orders
    @PutMapping("/{gameId}/orders")
    fun submitOrders(
        @PathVariable gameId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: SubmitOrdersRequest
    ): Mono<OrderSubmissionResponse> {
        return gameService.submitOrders(gameId, playerId, request)
    }

    // E4-S8: Propose draw
    @PostMapping("/{gameId}/draw")
    fun proposeDraw(
        @PathVariable gameId: UUID,
        @AuthenticationPrincipal playerId: UUID
    ): Mono<Void> {
        return gameService.proposeDraw(gameId, playerId)
    }
}
