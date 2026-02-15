package com.diplomacy.adjudication

/**
 * Resolves retreat phase orders.
 *
 * Rules:
 * - Dislodged units must retreat or disband
 * - Cannot retreat to: the territory from which the attacker came,
 *   an occupied territory, or a territory where a standoff occurred
 * - If two units retreat to the same territory, both are disbanded
 * - Units with no valid retreat destinations are automatically disbanded
 * - Units without orders are automatically disbanded
 */
class RetreatResolver(private val mapDefinition: MapDefinition) {

    fun resolve(gameState: GameState, orders: List<Order>): AdjudicationResult {
        require(gameState.phase == Phase.RETREAT) { "RetreatResolver requires RETREAT phase" }

        val resolvedOrders = mutableListOf<ResolvedOrder>()

        // Auto-disband dislodged units without orders
        val orderedTerritories = orders.map { it.unitTerritory }.toSet()
        for (dislodged in gameState.dislodgedUnits) {
            if (dislodged.unit.territoryId !in orderedTerritories) {
                resolvedOrders.add(
                    ResolvedOrder(
                        Order.Disband(dislodged.unit.power, dislodged.unit.territoryId),
                        OrderOutcome.SUCCEEDED,
                        "Auto-disbanded: no retreat order"
                    )
                )
            }
        }

        // Group retreats by destination to detect conflicts
        val retreatsByDest = mutableMapOf<String, MutableList<Order.Retreat>>()
        val disbands = mutableListOf<Order.Disband>()

        for (order in orders) {
            when (order) {
                is Order.Retreat -> {
                    retreatsByDest.getOrPut(order.destination) { mutableListOf() }.add(order)
                }
                is Order.Disband -> {
                    disbands.add(order)
                    resolvedOrders.add(ResolvedOrder(order, OrderOutcome.SUCCEEDED))
                }
                else -> {
                    resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, "Invalid order for retreat phase"))
                }
            }
        }

        // Resolve retreats — conflicts mean both disband
        val successfulRetreats = mutableListOf<Pair<Order.Retreat, MapUnit>>()

        for ((dest, retreats) in retreatsByDest) {
            if (retreats.size > 1) {
                // Conflict: all retreating units to this destination are disbanded
                for (retreat in retreats) {
                    resolvedOrders.add(
                        ResolvedOrder(retreat, OrderOutcome.BOUNCED, "Retreat conflict: multiple units retreating to $dest")
                    )
                }
            } else {
                val retreat = retreats[0]
                val dislodged = gameState.dislodgedUnits.find {
                    it.unit.territoryId == retreat.unitTerritory && it.unit.power == retreat.power
                }

                if (dislodged == null) {
                    resolvedOrders.add(ResolvedOrder(retreat, OrderOutcome.VOID, "Unit not found in dislodged list"))
                    continue
                }

                // Validate retreat destination
                val validationError = validateRetreatDestination(retreat, dislodged, gameState)
                if (validationError != null) {
                    resolvedOrders.add(ResolvedOrder(retreat, OrderOutcome.FAILED, validationError))
                } else {
                    resolvedOrders.add(ResolvedOrder(retreat, OrderOutcome.SUCCEEDED))
                    successfulRetreats.add(retreat to dislodged.unit)
                }
            }
        }

        // Build new unit list
        val newUnits = gameState.units.toMutableList()
        for ((retreat, unit) in successfulRetreats) {
            newUnits.add(unit.copy(territoryId = retreat.destination))
        }

        // Determine next phase
        val nextPhase = if (gameState.season == Season.FALL) Phase.BUILD else Phase.ORDER_SUBMISSION
        val nextSeason = if (gameState.season == Season.SPRING) Season.FALL else gameState.season
        val nextYear = if (gameState.season == Season.FALL && nextPhase == Phase.BUILD) {
            gameState.year + 1
        } else {
            gameState.year
        }

        val newGameState = GameState(
            phase = nextPhase,
            year = nextYear,
            season = nextSeason,
            units = newUnits,
            supplyCenterOwnership = gameState.supplyCenterOwnership,
            dislodgedUnits = emptyList(),
            standoffTerritories = emptySet()
        )

        return AdjudicationResult(
            resolvedOrders = resolvedOrders,
            newGameState = newGameState,
            dislodgedUnits = emptyList(),
            supplyCenterChanges = emptyList(),
            nextPhase = nextPhase
        )
    }

    private fun validateRetreatDestination(
        retreat: Order.Retreat,
        dislodged: DislodgedUnit,
        gameState: GameState
    ): String? {
        val dest = retreat.destination

        // Must be adjacent
        if (!mapDefinition.isAdjacent(retreat.unitTerritory, dest, dislodged.unit.type)) {
            return "Not adjacent"
        }

        // Cannot retreat to attacker's origin
        if (dest == dislodged.attackedFrom) {
            return "Cannot retreat to attacker's origin"
        }

        // Cannot retreat to occupied territory
        if (gameState.units.any { it.territoryId == dest }) {
            return "Territory occupied"
        }

        // Cannot retreat to standoff territory
        if (dest in gameState.standoffTerritories) {
            return "Standoff territory"
        }

        // Terrain check
        val destTerritory = mapDefinition.territories[dest]
        if (destTerritory != null) {
            if (dislodged.unit.type == UnitType.ARMY && destTerritory.type == TerritoryType.SEA) {
                return "Army cannot retreat to sea"
            }
            if (dislodged.unit.type == UnitType.FLEET && destTerritory.type == TerritoryType.LAND) {
                return "Fleet cannot retreat to inland"
            }
        }

        return null
    }
}
