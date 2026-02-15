package com.diplomacy.player

import jakarta.validation.constraints.Size
import java.math.BigDecimal
import java.time.Instant
import java.util.UUID

data class PlayerProfile(
    val id: UUID,
    val displayName: String,
    val email: String,
    val authProvider: String,
    val avatarUrl: String?,
    val eloClassic: Int,
    val elo1v1: Int,
    val eloVariant: Int,
    val peakEloClassic: Int,
    val rankTier: String,
    val reliabilityScore: BigDecimal,
    val gamesPlayed: Int,
    val gamesWon: Int,
    val gamesDrawn: Int,
    val createdAt: Instant
)

data class UpdateProfileRequest(
    @field:Size(min = 3, max = 50) val displayName: String? = null,
    @field:Size(max = 500) val avatarUrl: String? = null
)

fun Player.toProfile() = PlayerProfile(
    id = id!!,
    displayName = displayName,
    email = email,
    authProvider = authProvider,
    avatarUrl = avatarUrl,
    eloClassic = eloClassic,
    elo1v1 = elo1v1,
    eloVariant = eloVariant,
    peakEloClassic = peakEloClassic,
    rankTier = rankTier,
    reliabilityScore = reliabilityScore,
    gamesPlayed = gamesPlayed,
    gamesWon = gamesWon,
    gamesDrawn = gamesDrawn,
    createdAt = createdAt
)
