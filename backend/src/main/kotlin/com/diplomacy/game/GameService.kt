package com.diplomacy.game

import com.diplomacy.messaging.MessagingService
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.stereotype.Service
import org.springframework.transaction.reactive.TransactionalOperator
import org.springframework.transaction.reactive.executeAndAwait
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.security.SecureRandom
import java.time.Duration
import java.time.Instant
import java.util.UUID

@Service
class GameService(
    private val gameRepository: GameRepository,
    private val gamePlayerRepository: GamePlayerRepository,
    private val gameStateRepository: GameStateRepository,
    private val gameOrderRepository: GameOrderRepository,
    private val messagingService: MessagingService,
    private val objectMapper: ObjectMapper
) {

    private val random = SecureRandom()

    companion object {
        private val POWERS = listOf("ENGLAND", "FRANCE", "GERMANY", "ITALY", "AUSTRIA", "RUSSIA", "TURKEY")
        private const val INVITE_CODE_LENGTH = 8
        private const val INVITE_CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // no ambiguous chars
        private const val SOLO_VICTORY_SC_COUNT = 18
    }

    // ================================================================
    // E4-S1: CREATE GAME
    // ================================================================

    fun createGame(request: CreateGameRequest, creatorId: UUID): Mono<GameResponse> {
        val phaseLength = Duration.parse(request.phaseLength)
        val inviteCode = if (request.visibility == "PRIVATE") generateInviteCode() else null

        val game = Game(
            name = request.name,
            creatorId = creatorId,
            mapId = request.map,
            phaseLength = phaseLength,
            pressRules = request.pressRules,
            scoringSystem = request.scoring,
            minReliability = request.minReliability,
            isRanked = request.ranked,
            visibility = request.visibility,
            inviteCode = inviteCode,
            readReceipts = request.readReceipts,
            anonymousCountries = request.anonymousCountries
        )

        return gameRepository.save(game)
            .map { saved -> saved.toResponse() }
    }

    // ================================================================
    // E4-S2: JOIN GAME
    // ================================================================

    fun joinGameByInviteCode(inviteCode: String, playerId: UUID): Mono<GameResponse> {
        return gameRepository.findByInviteCode(inviteCode)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Invalid invite code")))
            .flatMap { game -> joinGame(game, playerId) }
    }

    fun joinGameById(gameId: UUID, playerId: UUID): Mono<GameResponse> {
        return gameRepository.findById(gameId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Game not found")))
            .flatMap { game -> joinGame(game, playerId) }
    }

    private fun joinGame(game: Game, playerId: UUID): Mono<GameResponse> {
        if (game.status != "WAITING_FOR_PLAYERS") {
            return Mono.error(IllegalStateException("Game is not accepting players"))
        }

        return gamePlayerRepository.findByGameIdAndPlayerId(game.id!!, playerId)
            .flatMap<GameResponse> { Mono.error(IllegalStateException("Already joined this game")) }
            .switchIfEmpty(
                gamePlayerRepository.findByGameId(game.id).collectList().flatMap { existingPlayers ->
                    if (existingPlayers.size >= 7) {
                        return@flatMap Mono.error<GameResponse>(IllegalStateException("Game is full"))
                    }

                    // Assign a temporary power placeholder (will be randomized on game start)
                    val assignedPowers = existingPlayers.map { it.power }.toSet()
                    val availablePower = POWERS.first { it !in assignedPowers }

                    val gamePlayer = GamePlayer(
                        gameId = game.id,
                        playerId = playerId,
                        power = availablePower
                    )

                    gamePlayerRepository.save(gamePlayer).flatMap { _ ->
                        val newCount = existingPlayers.size + 1
                        val updatedGame = game.copy(playerCount = newCount)

                        if (newCount == 7) {
                            startGame(updatedGame, existingPlayers + gamePlayer)
                        } else {
                            gameRepository.save(updatedGame).flatMap { saved ->
                                loadGameResponse(saved)
                            }
                        }
                    }
                }
            )
    }

    private fun startGame(game: Game, players: List<GamePlayer>): Mono<GameResponse> {
        // Randomly shuffle power assignments
        val shuffledPowers = POWERS.shuffled(random)
        val reassignedPlayers = players.mapIndexed { index, player ->
            player.copy(
                power = shuffledPowers[index],
                supplyCenterCount = if (shuffledPowers[index] == "RUSSIA") 4 else 3
            )
        }

        val now = Instant.now()
        val startedGame = game.copy(
            status = "IN_PROGRESS",
            currentPhase = "ORDER_SUBMISSION",
            currentSeason = "SPRING",
            currentYear = 1901,
            phaseDeadline = now.plus(game.phaseLength),
            startedAt = now,
            playerCount = 7
        )

        // Create initial game state
        val initialUnits = buildInitialUnits()
        val initialSupplyCenters = buildInitialSupplyCenters()

        val gameState = GameStateEntity(
            gameId = game.id!!,
            phase = "ORDER_SUBMISSION",
            season = "SPRING",
            year = 1901,
            phaseLabel = "S1901",
            units = objectMapper.writeValueAsString(initialUnits),
            supplyCenters = objectMapper.writeValueAsString(initialSupplyCenters),
            isInitial = true
        )

        return gameRepository.save(startedGame).flatMap { saved ->
            // Save reassigned players and initial state
            Flux.fromIterable(reassignedPlayers)
                .flatMap { player -> gamePlayerRepository.save(player) }
                .then(gameStateRepository.save(gameState))
                .then(
                    // E5-S1: Auto-create conversations on game start
                    messagingService.createConversationsForGame(
                        game.id,
                        reassignedPlayers.map { it.power to it.playerId }
                    )
                )
                .then(loadGameResponse(saved))
        }
    }

    // ================================================================
    // E4-S3: GET GAME STATE
    // ================================================================

    fun getGame(gameId: UUID): Mono<GameStateResponse> {
        return gameRepository.findById(gameId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Game not found")))
            .flatMap { game ->
                Mono.zip(
                    gamePlayerRepository.findByGameId(gameId).map { it.toSummary() }.collectList(),
                    gameStateRepository.findLatestByGameId(gameId)
                        .defaultIfEmpty(emptyGameState(gameId))
                ).map { tuple ->
                    val players = tuple.t1
                    val state = tuple.t2
                    val units = if (state.units.isNotEmpty()) {
                        objectMapper.readValue(
                            state.units,
                            objectMapper.typeFactory.constructCollectionType(List::class.java, UnitDto::class.java)
                        )
                    } else emptyList<UnitDto>()

                    val supplyCenters: Map<String, String?> = if (state.supplyCenters.isNotEmpty()) {
                        objectMapper.readValue(
                            state.supplyCenters,
                            objectMapper.typeFactory.constructMapType(Map::class.java, String::class.java, String::class.java)
                        )
                    } else emptyMap()

                    val dislodgedUnits = state.dislodgedUnits?.let {
                        objectMapper.readValue(
                            it,
                            objectMapper.typeFactory.constructCollectionType(List::class.java, DislodgedUnitDto::class.java)
                        )
                    }

                    GameStateResponse(
                        game = game.toResponse(players),
                        units = units,
                        supplyCenters = supplyCenters,
                        dislodgedUnits = dislodgedUnits
                    )
                }
            }
    }

    // ================================================================
    // E4-S4: SUBMIT ORDERS
    // ================================================================

    fun submitOrders(
        gameId: UUID,
        playerId: UUID,
        request: SubmitOrdersRequest
    ): Mono<OrderSubmissionResponse> {
        return gameRepository.findById(gameId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Game not found")))
            .flatMap { game ->
                if (game.status != "IN_PROGRESS") {
                    return@flatMap Mono.error<OrderSubmissionResponse>(
                        IllegalStateException("Game is not in progress")
                    )
                }

                gamePlayerRepository.findByGameIdAndPlayerId(gameId, playerId)
                    .switchIfEmpty(Mono.error(IllegalArgumentException("Not a participant")))
                    .flatMap { gamePlayer ->
                        if (gamePlayer.isEliminated) {
                            return@flatMap Mono.error<OrderSubmissionResponse>(
                                IllegalStateException("Player is eliminated")
                            )
                        }

                        val ordersJson = objectMapper.writeValueAsString(request.orders)

                        // Validate orders and produce validation results
                        val validationResults = validateOrders(request.orders, game)
                        val validationJson = objectMapper.writeValueAsString(validationResults)

                        val now = Instant.now()

                        // Delete existing orders for this phase, then insert new
                        gameOrderRepository.deleteByPlayerAndPhase(
                            gameId, playerId, game.currentSeason, game.currentYear, game.currentPhase
                        ).then(
                            gameOrderRepository.save(
                                GameOrderEntity(
                                    gameId = gameId,
                                    playerId = playerId,
                                    power = gamePlayer.power,
                                    phase = game.currentPhase,
                                    season = game.currentSeason,
                                    year = game.currentYear,
                                    orders = ordersJson,
                                    validationResults = validationJson,
                                    submittedAt = now
                                )
                            )
                        ).then(
                            // Update orders_submitted flag
                            gamePlayerRepository.save(gamePlayer.copy(ordersSubmitted = true))
                        ).then(
                            // Check for early adjudication (E4-S6)
                            checkEarlyAdjudication(gameId)
                        ).thenReturn(
                            OrderSubmissionResponse(
                                submitted = true,
                                submittedAt = now,
                                validationResults = validationResults
                            )
                        )
                    }
            }
    }

    // ================================================================
    // E4-S6: EARLY ADJUDICATION CHECK
    // ================================================================

    private fun checkEarlyAdjudication(gameId: UUID): Mono<Void> {
        return Mono.zip(
            gamePlayerRepository.countSubmittedOrders(gameId),
            gamePlayerRepository.countActivePlayers(gameId)
        ).flatMap { tuple ->
            val submitted = tuple.t1
            val active = tuple.t2
            if (submitted >= active && active > 0) {
                // All active players have submitted — trigger early adjudication
                gameRepository.findById(gameId).flatMap { game ->
                    gameRepository.save(game.copy(allOrdersSubmitted = true))
                }.then()
            } else {
                Mono.empty()
            }
        }
    }

    // ================================================================
    // E4-S7: DASHBOARD
    // ================================================================

    fun getPlayerGames(playerId: UUID): Flux<GameSummary> {
        return gamePlayerRepository.findByPlayerId(playerId)
            .flatMap { gp ->
                gameRepository.findById(gp.gameId).map { game ->
                    GameSummary(
                        gameId = game.id!!,
                        name = game.name,
                        status = game.status,
                        power = gp.power,
                        currentPhase = game.currentPhase,
                        currentSeason = game.currentSeason,
                        currentYear = game.currentYear,
                        phaseDeadline = game.phaseDeadline,
                        ordersSubmitted = gp.ordersSubmitted,
                        supplyCenterCount = gp.supplyCenterCount,
                        prevSupplyCenterCount = gp.prevSupplyCenterCount,
                        unreadMessageCount = gp.unreadMessageCount,
                        playerCount = game.playerCount
                    )
                }
            }
    }

    // ================================================================
    // E4-S8: GAME END DETECTION
    // ================================================================

    fun checkGameEnd(gameId: UUID, supplyCenterOwnership: Map<String, String>): Mono<Game> {
        return gameRepository.findById(gameId).flatMap { game ->
            // Count SCs per power
            val scCounts = supplyCenterOwnership.values.groupingBy { it }.eachCount()

            // Check for solo victory
            val winner = scCounts.entries.find { it.value >= SOLO_VICTORY_SC_COUNT }
            if (winner != null) {
                // Find the player with this power
                gamePlayerRepository.findByGameId(gameId)
                    .filter { it.power == winner.key }
                    .next()
                    .flatMap { winnerPlayer ->
                        val completedGame = game.copy(
                            status = "COMPLETED",
                            result = "SOLO_VICTORY",
                            winnerPower = winner.key,
                            winnerPlayerId = winnerPlayer.playerId,
                            completedAt = Instant.now()
                        )
                        gameRepository.save(completedGame)
                    }
            } else {
                // Check for eliminations (powers with 0 SCs)
                gamePlayerRepository.findByGameId(gameId)
                    .filter { !it.isEliminated }
                    .filter { player -> (scCounts[player.power] ?: 0) == 0 }
                    .flatMap { player ->
                        gamePlayerRepository.save(player.copy(isEliminated = true))
                    }
                    .then(Mono.just(game))
            }
        }
    }

    fun proposeDraw(gameId: UUID, playerId: UUID): Mono<Void> {
        // Simplified draw: all remaining players must agree
        // Full implementation would track individual votes
        return gameRepository.findById(gameId).flatMap { game ->
            if (game.status != "IN_PROGRESS") {
                return@flatMap Mono.error<Void>(IllegalStateException("Game is not in progress"))
            }
            // For now, mark game as draw if all active players agree
            // This would need a draw proposal tracking table in a full implementation
            val completedGame = game.copy(
                status = "COMPLETED",
                result = "DRAW",
                completedAt = Instant.now()
            )
            gameRepository.save(completedGame).then()
        }
    }

    // ================================================================
    // HELPERS
    // ================================================================

    private fun loadGameResponse(game: Game): Mono<GameResponse> {
        return gamePlayerRepository.findByGameId(game.id!!)
            .map { it.toSummary() }
            .collectList()
            .map { players -> game.toResponse(players) }
    }

    private fun generateInviteCode(): String {
        return (1..INVITE_CODE_LENGTH)
            .map { INVITE_CODE_CHARS[random.nextInt(INVITE_CODE_CHARS.length)] }
            .joinToString("")
    }

    private fun validateOrders(orders: List<OrderDto>, game: Game): List<OrderValidationResult> {
        // Basic validation — full validation integrates with adjudication engine
        return orders.map { order ->
            val orderStr = formatOrder(order)
            when {
                order.type.isBlank() -> OrderValidationResult(orderStr, "INVALID", error = "Missing order type")
                order.type == "MOVE" && order.destination == null ->
                    OrderValidationResult(orderStr, "INVALID", error = "Move requires destination")
                order.type == "SUPPORT" && order.supportTarget == null ->
                    OrderValidationResult(orderStr, "INVALID", error = "Support requires target")
                order.type == "BUILD" && order.unitType == null ->
                    OrderValidationResult(orderStr, "INVALID", error = "Build requires unit type")
                else -> OrderValidationResult(orderStr, "VALID")
            }
        }
    }

    private fun formatOrder(order: OrderDto): String {
        return when (order.type) {
            "HOLD" -> "${order.origin} HOLD"
            "MOVE" -> "${order.origin} -> ${order.destination}"
            "SUPPORT" -> "${order.origin} S ${order.supportTarget?.origin} -> ${order.supportTarget?.destination ?: order.supportTarget?.origin}"
            "CONVOY" -> "${order.origin} C ${order.convoyTarget?.origin} -> ${order.convoyTarget?.destination}"
            "RETREAT" -> "${order.origin} R ${order.destination}"
            "DISBAND" -> "${order.origin ?: order.territory} DISBAND"
            "BUILD" -> "BUILD ${order.unitType} ${order.territory}"
            "WAIVE" -> "WAIVE"
            else -> order.type
        }
    }

    private fun emptyGameState(gameId: UUID) = GameStateEntity(
        gameId = gameId,
        phase = "ORDER_SUBMISSION",
        season = "SPRING",
        year = 1901,
        phaseLabel = "S1901",
        units = "[]",
        supplyCenters = "{}"
    )

    private fun buildInitialUnits(): List<UnitDto> = listOf(
        UnitDto("AUSTRIA", "ARMY", "VIE"),
        UnitDto("AUSTRIA", "ARMY", "BUD"),
        UnitDto("AUSTRIA", "FLEET", "TRI"),
        UnitDto("ENGLAND", "FLEET", "LON"),
        UnitDto("ENGLAND", "FLEET", "EDI"),
        UnitDto("ENGLAND", "ARMY", "LVP"),
        UnitDto("FRANCE", "ARMY", "PAR"),
        UnitDto("FRANCE", "ARMY", "MAR"),
        UnitDto("FRANCE", "FLEET", "BRE"),
        UnitDto("GERMANY", "ARMY", "BER"),
        UnitDto("GERMANY", "ARMY", "MUN"),
        UnitDto("GERMANY", "FLEET", "KIE"),
        UnitDto("ITALY", "ARMY", "ROM"),
        UnitDto("ITALY", "ARMY", "VEN"),
        UnitDto("ITALY", "FLEET", "NAP"),
        UnitDto("RUSSIA", "ARMY", "MOS"),
        UnitDto("RUSSIA", "ARMY", "WAR"),
        UnitDto("RUSSIA", "FLEET", "SEV"),
        UnitDto("RUSSIA", "FLEET", "STP_SC"),
        UnitDto("TURKEY", "ARMY", "CON"),
        UnitDto("TURKEY", "ARMY", "SMY"),
        UnitDto("TURKEY", "FLEET", "ANK")
    )

    private fun buildInitialSupplyCenters(): Map<String, String> = mapOf(
        "VIE" to "AUSTRIA", "BUD" to "AUSTRIA", "TRI" to "AUSTRIA",
        "LON" to "ENGLAND", "EDI" to "ENGLAND", "LVP" to "ENGLAND",
        "PAR" to "FRANCE", "MAR" to "FRANCE", "BRE" to "FRANCE",
        "BER" to "GERMANY", "MUN" to "GERMANY", "KIE" to "GERMANY",
        "ROM" to "ITALY", "VEN" to "ITALY", "NAP" to "ITALY",
        "MOS" to "RUSSIA", "WAR" to "RUSSIA", "SEV" to "RUSSIA", "STP" to "RUSSIA",
        "CON" to "TURKEY", "SMY" to "TURKEY", "ANK" to "TURKEY"
    )
}
