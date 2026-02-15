package com.diplomacy.auth

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant
import java.util.UUID

data class RegisterRequest(
    @field:NotBlank val provider: String,
    @field:Email @field:NotBlank val email: String,
    @field:Size(min = 8, max = 128) val password: String? = null,
    @field:NotBlank @field:Size(min = 3, max = 50) val displayName: String,
    val idToken: String? = null
)

data class LoginRequest(
    @field:Email @field:NotBlank val email: String,
    @field:NotBlank val password: String
)

data class RefreshRequest(
    @field:NotBlank val refreshToken: String
)

data class AppleLoginRequest(
    @field:NotBlank val idToken: String,
    val displayName: String? = null
)

data class AuthResponse(
    val accessToken: String,
    val refreshToken: String,
    val player: PlayerSummary
)

data class PlayerSummary(
    val id: UUID,
    val displayName: String,
    val elo: Int,
    val reliability: Double,
    val rank: String,
    val createdAt: Instant
)
