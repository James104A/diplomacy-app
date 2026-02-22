package com.diplomacy.game

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Duration
import java.time.Instant
import java.util.UUID

// ================================================================
// CREATE GAME
// ================================================================

data class CreateGameRequest(
    @field:NotBlank @field:Size(max = 100)
    val name: String,
    val map: String = "CLASSIC",
    val phaseLength: String = "PT24H", // ISO 8601 duration
    val pressRules: String = "FULL_PRESS",
    val scoring: String = "DRAW_SIZE",
    val minReliability: Int = 70,
    val ranked: Boolean = true,
    val visibility: String = "PUBLIC",
    val readReceipts: Boolean = false,
    val anonymousCountries: Boolean = false
)

data class GameResponse(
    val id: UUID,
    val name: String,
    val status: String,
    val creatorId: UUID,
    val settings: GameSettings,
    val players: List<GamePlayerSummary>,
    val inviteCode: String?,
    val currentPhase: String,
    val currentSeason: String,
    val currentYear: Int,
    val phaseDeadline: Instant?,
    val createdAt: Instant,
    val startedAt: Instant?
)

data class GameSettings(
    val map: String,
    val phaseLength: String,
    val pressRules: String,
    val scoring: String,
    val minReliability: Int,
    val ranked: Boolean,
    val readReceipts: Boolean,
    val anonymousCountries: Boolean
)

data class GamePlayerSummary(
    val playerId: UUID,
    val power: String,
    val ordersSubmitted: Boolean,
    val isEliminated: Boolean,
    val supplyCenterCount: Int
)

// ================================================================
// GAME STATE
// ================================================================

data class GameStateResponse(
    val game: GameResponse,
    val units: List<UnitDto>,
    val supplyCenters: Map<String, String?>,
    val dislodgedUnits: List<DislodgedUnitDto>?
)

data class UnitDto(
    val power: String,
    val type: String,
    val territoryId: String
)

data class DislodgedUnitDto(
    val power: String,
    val type: String,
    val territoryId: String,
    val attackedFrom: String
)

// ================================================================
// ORDERS
// ================================================================

data class SubmitOrdersRequest(
    val orders: List<OrderDto>
)

data class OrderDto(
    val type: String,
    val origin: String? = null,
    val destination: String? = null,
    val supportTarget: SupportTargetDto? = null,
    val convoyTarget: ConvoyTargetDto? = null,
    val territory: String? = null,
    val unitType: String? = null,
    val coast: String? = null,
    val viaConvoy: Boolean = false
)

data class SupportTargetDto(
    val origin: String,
    val destination: String? = null
)

data class ConvoyTargetDto(
    val origin: String,
    val destination: String
)

data class OrderSubmissionResponse(
    val submitted: Boolean,
    val submittedAt: Instant,
    val validationResults: List<OrderValidationResult>
)

data class OrderValidationResult(
    val order: String,
    val status: String, // VALID, WARNING, INVALID
    val warning: String? = null,
    val error: String? = null
)

// ================================================================
// DASHBOARD
// ================================================================

data class GameSummary(
    val gameId: UUID,
    val name: String,
    val status: String,
    val power: String,
    val currentPhase: String,
    val currentSeason: String,
    val currentYear: Int,
    val phaseDeadline: Instant?,
    val ordersSubmitted: Boolean,
    val supplyCenterCount: Int,
    val prevSupplyCenterCount: Int,
    val unreadMessageCount: Int,
    val playerCount: Int
)

// ================================================================
// EXTENSIONS
// ================================================================

fun Game.toResponse(players: List<GamePlayerSummary> = emptyList()) = GameResponse(
    id = id!!,
    name = name,
    status = status,
    creatorId = creatorId,
    settings = GameSettings(
        map = mapId,
        phaseLength = Duration.ofSeconds(phaseLength).toString(),
        pressRules = pressRules,
        scoring = scoringSystem,
        minReliability = minReliability,
        ranked = isRanked,
        readReceipts = readReceipts,
        anonymousCountries = anonymousCountries
    ),
    players = players,
    inviteCode = inviteCode,
    currentPhase = currentPhase,
    currentSeason = currentSeason,
    currentYear = currentYear,
    phaseDeadline = phaseDeadline,
    createdAt = createdAt,
    startedAt = startedAt
)

fun GamePlayer.toSummary() = GamePlayerSummary(
    playerId = playerId,
    power = power,
    ordersSubmitted = ordersSubmitted,
    isEliminated = isEliminated,
    supplyCenterCount = supplyCenterCount
)
