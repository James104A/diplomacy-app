package com.diplomacy.auth

import com.diplomacy.player.Player
import com.diplomacy.player.PlayerRepository
import org.springframework.data.redis.core.ReactiveStringRedisTemplate
import org.springframework.http.HttpStatus
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.web.server.ResponseStatusException
import reactor.core.publisher.Mono
import java.time.Duration

@Service
class AuthService(
    private val playerRepository: PlayerRepository,
    private val jwtService: JwtService,
    private val jwtProperties: JwtProperties,
    private val passwordEncoder: PasswordEncoder,
    private val redisTemplate: ReactiveStringRedisTemplate,
    private val appleTokenVerifier: AppleTokenVerifier
) {

    fun register(request: RegisterRequest): Mono<AuthResponse> {
        if (request.provider == "email" && request.password.isNullOrBlank()) {
            return Mono.error(ResponseStatusException(HttpStatus.BAD_REQUEST, "Password required for email registration"))
        }

        return playerRepository.findByEmail(request.email)
            .flatMap<AuthResponse> {
                Mono.error(ResponseStatusException(HttpStatus.CONFLICT, "Email already registered"))
            }
            .switchIfEmpty(
                playerRepository.findByDisplayName(request.displayName)
                    .flatMap<AuthResponse> {
                        Mono.error(ResponseStatusException(HttpStatus.CONFLICT, "Display name already taken"))
                    }
                    .switchIfEmpty(createPlayerAndTokens(request))
            )
    }

    fun login(request: LoginRequest): Mono<AuthResponse> {
        return playerRepository.findByEmail(request.email)
            .filter { it.deletedAt == null }
            .filter { it.passwordHash != null && passwordEncoder.matches(request.password, it.passwordHash) }
            .flatMap { player -> generateTokens(player) }
            .switchIfEmpty(Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials")))
    }

    fun refresh(request: RefreshRequest): Mono<AuthResponse> {
        val claims = jwtService.validateToken(request.refreshToken)
            ?: return Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"))

        if (claims["type"] != "refresh") {
            return Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token type"))
        }

        val jti = claims.id
            ?: return Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"))

        val redisKey = "refresh:$jti"

        return redisTemplate.opsForValue().setIfAbsent(redisKey, "used", Duration.ofSeconds(jwtProperties.refreshTokenExpiration))
            .flatMap { wasNew ->
                if (wasNew != true) {
                    Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token already used"))
                } else {
                    val playerId = java.util.UUID.fromString(claims.subject)
                    playerRepository.findById(playerId)
                        .filter { it.deletedAt == null }
                        .flatMap { player -> generateTokens(player) }
                        .switchIfEmpty(Mono.error(ResponseStatusException(HttpStatus.UNAUTHORIZED, "Player not found")))
                }
            }
    }

    fun loginWithApple(request: AppleLoginRequest): Mono<AuthResponse> {
        return appleTokenVerifier.verify(request.idToken)
            .flatMap { payload ->
                val email = payload.email
                    ?: return@flatMap Mono.error<AuthResponse>(
                        ResponseStatusException(HttpStatus.BAD_REQUEST, "Apple token missing email")
                    )

                playerRepository.findByEmail(email)
                    .filter { it.deletedAt == null }
                    .flatMap { player -> generateTokens(player) }
                    .switchIfEmpty(
                        createApplePlayer(email, payload.sub, request.displayName)
                    )
            }
            .onErrorMap({ it !is ResponseStatusException }) {
                ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid Apple token")
            }
    }

    private fun createApplePlayer(email: String, appleSub: String, displayName: String?): Mono<AuthResponse> {
        val name = displayName ?: "Player_${appleSub.take(8)}"
        val player = Player(
            displayName = name,
            email = email,
            authProvider = "APPLE"
        )
        return playerRepository.save(player)
            .flatMap { saved -> generateTokens(saved) }
    }

    private fun createPlayerAndTokens(request: RegisterRequest): Mono<AuthResponse> {
        val player = Player(
            displayName = request.displayName,
            email = request.email,
            passwordHash = request.password?.let { passwordEncoder.encode(it) },
            authProvider = request.provider.uppercase()
        )

        return playerRepository.save(player)
            .flatMap { saved -> generateTokens(saved) }
    }

    private fun generateTokens(player: Player): Mono<AuthResponse> {
        val playerId = player.id!!
        val accessToken = jwtService.generateAccessToken(playerId)
        val refreshToken = jwtService.generateRefreshToken(playerId)

        return Mono.just(
            AuthResponse(
                accessToken = accessToken,
                refreshToken = refreshToken,
                player = PlayerSummary(
                    id = playerId,
                    displayName = player.displayName,
                    elo = player.eloClassic,
                    reliability = player.reliabilityScore.toDouble(),
                    rank = player.rankTier,
                    createdAt = player.createdAt
                )
            )
        )
    }
}
