package com.diplomacy.auth

import com.diplomacy.player.PlayerService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
@RequestMapping("/v1/auth")
class AuthController(
    private val authService: AuthService,
    private val playerService: PlayerService
) {

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    fun register(@Valid @RequestBody request: RegisterRequest): Mono<AuthResponse> {
        return authService.register(request)
    }

    @PostMapping("/login")
    fun login(@Valid @RequestBody request: LoginRequest): Mono<AuthResponse> {
        return authService.login(request)
    }

    @PostMapping("/login/apple")
    fun loginWithApple(@Valid @RequestBody request: AppleLoginRequest): Mono<AuthResponse> {
        return authService.loginWithApple(request)
    }

    @PostMapping("/refresh")
    fun refresh(@Valid @RequestBody request: RefreshRequest): Mono<AuthResponse> {
        return authService.refresh(request)
    }

    @DeleteMapping("/account")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteAccount(@AuthenticationPrincipal playerId: UUID): Mono<Void> {
        return playerService.deleteAccount(playerId)
    }
}
