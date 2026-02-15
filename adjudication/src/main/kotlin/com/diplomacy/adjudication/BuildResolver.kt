package com.diplomacy.adjudication

/**
 * Resolves build/disband phase (adjustment phase).
 *
 * Rules:
 * - After Fall, each power counts supply centers owned vs units on board
 * - If SCs > units: power may BUILD up to the difference
 * - If SCs < units: power MUST DISBAND the difference
 * - Builds only on unoccupied home supply centers owned by the power
 * - If power doesn't submit enough disbands, furthest units from home are auto-disbanded
 * - Waive orders explicitly decline a build
 */
class BuildResolver(private val mapDefinition: MapDefinition) {

    fun resolve(gameState: GameState, orders: List<Order>): AdjudicationResult {
        require(gameState.phase == Phase.BUILD) { "BuildResolver requires BUILD phase" }

        val resolvedOrders = mutableListOf<ResolvedOrder>()
        val newUnits = gameState.units.toMutableList()

        // Calculate adjustments per power
        for (power in Power.entries) {
            val scCount = gameState.supplyCenterOwnership.count { it.value == power }
            val unitCount = gameState.units.count { it.power == power }
            val adjustment = scCount - unitCount

            val powerOrders = orders.filter { it.power == power }

            if (adjustment > 0) {
                // Power may build
                resolveBuildOrders(power, adjustment, powerOrders, gameState, resolvedOrders, newUnits)
            } else if (adjustment < 0) {
                // Power must disband
                resolveDisbandOrders(power, -adjustment, powerOrders, gameState, resolvedOrders, newUnits)
            }
            // adjustment == 0: no action needed
        }

        val newGameState = GameState(
            phase = Phase.ORDER_SUBMISSION,
            year = gameState.year,
            season = Season.SPRING,
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
            nextPhase = Phase.ORDER_SUBMISSION
        )
    }

    private fun resolveBuildOrders(
        power: Power,
        maxBuilds: Int,
        orders: List<Order>,
        gameState: GameState,
        resolvedOrders: MutableList<ResolvedOrder>,
        newUnits: MutableList<MapUnit>
    ) {
        var buildsUsed = 0

        for (order in orders) {
            when (order) {
                is Order.Build -> {
                    if (buildsUsed >= maxBuilds) {
                        resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, "No more builds available"))
                        continue
                    }

                    val error = validateBuild(order, gameState, newUnits)
                    if (error != null) {
                        resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, error))
                    } else {
                        resolvedOrders.add(ResolvedOrder(order, OrderOutcome.SUCCEEDED))
                        newUnits.add(MapUnit(order.power, order.unitType, order.unitTerritory))
                        buildsUsed++
                    }
                }
                is Order.Waive -> {
                    if (buildsUsed >= maxBuilds) {
                        resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, "No more builds to waive"))
                    } else {
                        resolvedOrders.add(ResolvedOrder(order, OrderOutcome.SUCCEEDED))
                        buildsUsed++
                    }
                }
                else -> {
                    resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, "Invalid order for build adjustment"))
                }
            }
        }
    }

    private fun resolveDisbandOrders(
        power: Power,
        requiredDisbands: Int,
        orders: List<Order>,
        gameState: GameState,
        resolvedOrders: MutableList<ResolvedOrder>,
        newUnits: MutableList<MapUnit>
    ) {
        var disbanded = 0

        // Process explicit disband orders
        for (order in orders) {
            if (order is Order.Disband && disbanded < requiredDisbands) {
                val unit = newUnits.find { it.territoryId == order.unitTerritory && it.power == power }
                if (unit != null) {
                    resolvedOrders.add(ResolvedOrder(order, OrderOutcome.SUCCEEDED))
                    newUnits.remove(unit)
                    disbanded++
                } else {
                    resolvedOrders.add(ResolvedOrder(order, OrderOutcome.VOID, "Unit not found"))
                }
            }
        }

        // Auto-disband remaining if not enough explicit disbands
        while (disbanded < requiredDisbands) {
            val powerUnits = newUnits.filter { it.power == power }
            if (powerUnits.isEmpty()) break

            // Disband the unit furthest from any home supply center (simplified: just take last)
            val toDisband = selectAutoDisband(powerUnits, power)
            val autoOrder = Order.Disband(power, toDisband.territoryId)
            resolvedOrders.add(ResolvedOrder(autoOrder, OrderOutcome.SUCCEEDED, "Auto-disbanded: insufficient disband orders"))
            newUnits.remove(toDisband)
            disbanded++
        }
    }

    private fun selectAutoDisband(units: List<MapUnit>, power: Power): MapUnit {
        // Simplified heuristic: disband units furthest from home centers
        // In a full implementation, this would use shortest-path distance
        // For now: prefer disbanding fleets in sea zones, then units not on home SCs
        val homeSCs = mapDefinition.territories.values
            .filter { it.homeCenter == power && it.isSupplyCenter }
            .map { it.id }
            .toSet()

        // Units not on home SCs first
        val notOnHome = units.filter { it.territoryId !in homeSCs }
        if (notOnHome.isNotEmpty()) return notOnHome.last()

        return units.last()
    }

    private fun validateBuild(
        order: Order.Build,
        gameState: GameState,
        currentUnits: List<MapUnit>
    ): String? {
        val territory = mapDefinition.territories[order.unitTerritory]
            ?: return "Unknown territory"

        // Resolve parent for multi-coast
        val effectiveTerritory = if (territory.parentTerritory != null) {
            mapDefinition.territories[territory.parentTerritory] ?: return "Unknown parent territory"
        } else {
            territory
        }

        if (effectiveTerritory.homeCenter != order.power) {
            return "Not a home supply center"
        }

        if (!effectiveTerritory.isSupplyCenter) {
            return "Not a supply center"
        }

        // Must be owned by this power
        if (gameState.supplyCenterOwnership[effectiveTerritory.id] != order.power) {
            return "Supply center not owned"
        }

        // Must be unoccupied
        val isOccupied = currentUnits.any { unit ->
            unit.territoryId == effectiveTerritory.id ||
                (effectiveTerritory.coasts.isNotEmpty() && unit.territoryId in effectiveTerritory.coasts)
        }
        if (isOccupied) {
            return "Territory occupied"
        }

        // Fleet cannot be built on inland
        if (order.unitType == UnitType.FLEET && effectiveTerritory.type == TerritoryType.LAND) {
            return "Cannot build fleet on inland territory"
        }

        // Fleet on multi-coast must specify coast
        if (order.unitType == UnitType.FLEET && effectiveTerritory.coasts.isNotEmpty() &&
            order.unitTerritory == effectiveTerritory.id
        ) {
            return "Must specify coast for fleet build"
        }

        return null
    }
}
