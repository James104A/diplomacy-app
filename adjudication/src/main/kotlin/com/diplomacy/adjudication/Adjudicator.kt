package com.diplomacy.adjudication

/**
 * Main entry point for the adjudication engine.
 * Routes orders to the appropriate phase resolver.
 *
 * This is the public API that the backend service calls.
 */
class Adjudicator(private val mapDefinition: MapDefinition = ClassicMap.definition) {

    private val movementResolver = MovementResolver(mapDefinition)
    private val retreatResolver = RetreatResolver(mapDefinition)
    private val buildResolver = BuildResolver(mapDefinition)

    /**
     * Adjudicates the given orders against the current game state.
     * Orders are first validated, then resolved according to the current phase.
     */
    fun adjudicate(gameState: GameState, orders: List<Order>): AdjudicationResult {
        // Validate orders
        val validatedOrders = orders.map { order ->
            val result = OrderValidator.validate(order, gameState, mapDefinition)
            if (result.valid) {
                order
            } else {
                // Use fallback order if available, otherwise drop the order
                result.fallbackOrder ?: order
            }
        }.filter { order ->
            // Only keep orders that passed validation or have valid fallbacks
            val result = OrderValidator.validate(order, gameState, mapDefinition)
            result.valid
        }

        return when (gameState.phase) {
            Phase.DIPLOMACY, Phase.ORDER_SUBMISSION -> movementResolver.resolve(gameState, validatedOrders)
            Phase.RETREAT -> retreatResolver.resolve(gameState, validatedOrders)
            Phase.BUILD -> buildResolver.resolve(gameState, validatedOrders)
        }
    }

    /**
     * Creates the initial game state for a new game using this map.
     */
    fun createInitialGameState(): GameState {
        val units = mapDefinition.startingPositions.values.flatten().map { start ->
            MapUnit(start.power, start.unitType, start.territoryId)
        }

        val ownership = mutableMapOf<String, Power>()
        for ((_, territory) in mapDefinition.territories) {
            if (territory.homeCenter != null && territory.isSupplyCenter) {
                ownership[territory.id] = territory.homeCenter
            }
        }

        return GameState(
            phase = Phase.ORDER_SUBMISSION,
            year = 1901,
            season = Season.SPRING,
            units = units,
            supplyCenterOwnership = ownership
        )
    }
}
