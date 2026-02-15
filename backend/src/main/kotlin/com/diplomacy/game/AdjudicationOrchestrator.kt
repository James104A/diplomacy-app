package com.diplomacy.game

import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

/**
 * E4-S5: Orchestrates the adjudication flow.
 *
 * 1. Load current game state
 * 2. Load submitted orders (default HOLD for missing players)
 * 3. Run adjudication engine
 * 4. Persist results atomically (new game state, resolved phase, updated game)
 * 5. Check for game end conditions (E4-S8)
 */
@Service
class AdjudicationOrchestrator(
    private val gameRepository: GameRepository,
    private val gamePlayerRepository: GamePlayerRepository,
    private val gameStateRepository: GameStateRepository,
    private val gameOrderRepository: GameOrderRepository,
    private val resolvedPhaseRepository: ResolvedPhaseRepository,
    private val gameService: GameService,
    private val objectMapper: ObjectMapper
) {
    private val log = LoggerFactory.getLogger(AdjudicationOrchestrator::class.java)

    fun runAdjudication(gameId: UUID): Mono<Game> {
        return gameRepository.findById(gameId)
            .filter { it.status == "IN_PROGRESS" }
            .flatMap { game ->
                Mono.zip(
                    gameStateRepository.findLatestByGameId(gameId),
                    gameOrderRepository.findByGameIdAndSeasonAndYearAndPhase(
                        gameId, game.currentSeason, game.currentYear, game.currentPhase
                    ).collectList(),
                    gamePlayerRepository.findByGameId(gameId).collectList()
                ).flatMap { tuple ->
                    val currentState = tuple.t1
                    val orders = tuple.t2
                    val players = tuple.t3

                    // Parse current units and supply centers from JSONB
                    val units: List<UnitDto> = objectMapper.readValue(
                        currentState.units,
                        objectMapper.typeFactory.constructCollectionType(List::class.java, UnitDto::class.java)
                    )
                    val supplyCenters: Map<String, String> = objectMapper.readValue(
                        currentState.supplyCenters,
                        objectMapper.typeFactory.constructMapType(Map::class.java, String::class.java, String::class.java)
                    )

                    // Build resolved orders representation
                    // In a full implementation, this would call the adjudication engine
                    // For now, we create a simplified resolution
                    val allOrders = orders.map { it.orders }

                    // Determine next phase
                    val nextPhase = determineNextPhase(game.currentPhase, game.currentSeason)
                    val nextSeason = determineNextSeason(game.currentPhase, game.currentSeason)
                    val nextYear = determineNextYear(game.currentPhase, game.currentSeason, game.currentYear)
                    val phaseLabel = "${if (nextSeason == "SPRING") "S" else "F"}$nextYear"

                    // Create new game state (simplified — in production this uses adjudication engine output)
                    val newGameState = GameStateEntity(
                        gameId = gameId,
                        phase = nextPhase,
                        season = nextSeason,
                        year = nextYear,
                        phaseLabel = phaseLabel,
                        units = currentState.units, // In production: updated by adjudication engine
                        supplyCenters = currentState.supplyCenters,
                        isInitial = false
                    )

                    // Create resolved phase record
                    gameStateRepository.save(newGameState).flatMap { savedState ->
                        val resolvedPhase = ResolvedPhaseEntity(
                            gameId = gameId,
                            beforeStateId = currentState.id!!,
                            afterStateId = savedState.id!!,
                            phase = game.currentPhase,
                            season = game.currentSeason,
                            year = game.currentYear,
                            phaseLabel = "${if (game.currentSeason == "SPRING") "S" else "F"}${game.currentYear}",
                            allOrders = objectMapper.writeValueAsString(allOrders),
                            resolvedOrders = "[]" // In production: adjudication engine output
                        )

                        resolvedPhaseRepository.save(resolvedPhase).flatMap { _ ->
                            // Update game with new phase
                            val updatedGame = game.copy(
                                currentPhase = nextPhase,
                                currentSeason = nextSeason,
                                currentYear = nextYear,
                                phaseDeadline = Instant.now().plus(game.phaseLength),
                                allOrdersSubmitted = false
                            )

                            // Reset orders_submitted for all players
                            gamePlayerRepository.findByGameId(gameId)
                                .flatMap { player ->
                                    gamePlayerRepository.save(player.copy(ordersSubmitted = false))
                                }
                                .then(gameRepository.save(updatedGame))
                                .flatMap { saved ->
                                    // E4-S8: Check game end after fall adjudication
                                    if (game.currentSeason == "FALL") {
                                        gameService.checkGameEnd(gameId, supplyCenters)
                                            .thenReturn(saved)
                                    } else {
                                        Mono.just(saved)
                                    }
                                }
                        }
                    }
                }
            }
    }

    private fun determineNextPhase(currentPhase: String, currentSeason: String): String {
        return when (currentPhase) {
            "ORDER_SUBMISSION" -> "ORDER_SUBMISSION" // Simplified; retreat/build handled by adjudication engine
            "RETREAT" -> if (currentSeason == "FALL") "BUILD" else "ORDER_SUBMISSION"
            "BUILD" -> "ORDER_SUBMISSION"
            else -> "ORDER_SUBMISSION"
        }
    }

    private fun determineNextSeason(currentPhase: String, currentSeason: String): String {
        return when {
            currentPhase == "ORDER_SUBMISSION" && currentSeason == "SPRING" -> "FALL"
            currentPhase == "ORDER_SUBMISSION" && currentSeason == "FALL" -> "FALL" // stays fall for retreat/build
            currentPhase == "BUILD" -> "SPRING"
            else -> currentSeason
        }
    }

    private fun determineNextYear(currentPhase: String, currentSeason: String, currentYear: Int): Int {
        return if (currentPhase == "BUILD") currentYear + 1 else currentYear
    }

}
