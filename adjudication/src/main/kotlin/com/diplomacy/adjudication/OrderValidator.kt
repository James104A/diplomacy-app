package com.diplomacy.adjudication

/**
 * Validates orders in two passes: syntactic (well-formed) then semantic (legal given game state).
 * Invalid orders are converted to HOLD or DISBAND as appropriate, with error codes.
 */
object OrderValidator {

    data class ValidationResult(
        val order: Order,
        val valid: Boolean,
        val errorCode: String? = null,
        val fallbackOrder: Order? = null
    )

    fun validate(
        order: Order,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        val syntacticResult = validateSyntactic(order, gameState, mapDefinition)
        if (!syntacticResult.valid) return syntacticResult
        return validateSemantic(order, gameState, mapDefinition)
    }

    // ================================================================
    // SYNTACTIC VALIDATION — well-formed structure checks
    // ================================================================

    private fun validateSyntactic(
        order: Order,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        // 1. Order type valid for current phase
        val phaseError = validatePhase(order, gameState.phase)
        if (phaseError != null) return phaseError

        // 2. Unit referenced in order exists on board (except Build/Waive)
        if (order !is Order.Build && order !is Order.Waive) {
            val unit = findUnit(order, gameState)
            if (unit == null) {
                // For retreats, check dislodged units
                if (order is Order.Retreat || order is Order.Disband) {
                    val dislodged = gameState.dislodgedUnits.find {
                        it.unit.territoryId == order.unitTerritory && it.unit.power == order.power
                    }
                    if (dislodged == null) {
                        return invalid(order, "VOID: Unit not found")
                    }
                } else {
                    return invalid(order, "VOID: Unit not found")
                }
            }

            // 3. Unit belongs to ordering power
            if (order !is Order.Retreat && order !is Order.Disband) {
                val unit2 = findUnit(order, gameState)
                if (unit2 != null && unit2.power != order.power) {
                    return invalid(order, "VOID: Not your unit")
                }
            }
        }

        // 4. Destination territory exists on map (for orders with destinations)
        when (order) {
            is Order.Move -> if (mapDefinition.territories[order.destination] == null)
                return invalid(order, "VOID: Unknown territory")
            is Order.Support -> {
                if (mapDefinition.territories[order.supportedUnit] == null)
                    return invalid(order, "VOID: Unknown territory")
                if (order.supportedDestination != null && mapDefinition.territories[order.supportedDestination] == null)
                    return invalid(order, "VOID: Unknown territory")
            }
            is Order.Convoy -> {
                if (mapDefinition.territories[order.destination] == null)
                    return invalid(order, "VOID: Unknown territory")
                if (mapDefinition.territories[order.convoyedArmy] == null)
                    return invalid(order, "VOID: Unknown territory")
            }
            is Order.Retreat -> if (mapDefinition.territories[order.destination] == null)
                return invalid(order, "VOID: Unknown territory")
            is Order.Build -> if (mapDefinition.territories[order.unitTerritory] == null)
                return invalid(order, "VOID: Unknown territory")
            else -> {}
        }

        // 5. For SUPPORT: target unit exists
        if (order is Order.Support) {
            val supportTarget = gameState.units.find { it.territoryId == order.supportedUnit }
            if (supportTarget == null) {
                return invalid(order, "VOID: Support target not found")
            }
        }

        // 6. For CONVOY: fleet in sea zone, army on land
        if (order is Order.Convoy) {
            val convoyFleet = findUnit(order, gameState)
            if (convoyFleet != null) {
                val fleetTerritory = mapDefinition.territories[convoyFleet.territoryId]
                if (fleetTerritory?.type != TerritoryType.SEA) {
                    return invalid(order, "VOID: Invalid convoy configuration")
                }
            }
            val convoyedArmy = gameState.units.find { it.territoryId == order.convoyedArmy }
            if (convoyedArmy != null && convoyedArmy.type != UnitType.ARMY) {
                return invalid(order, "VOID: Invalid convoy configuration")
            }
        }

        return valid(order)
    }

    // ================================================================
    // SEMANTIC VALIDATION — legal given game state
    // ================================================================

    private fun validateSemantic(
        order: Order,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        return when (order) {
            is Order.Move -> validateMove(order, gameState, mapDefinition)
            is Order.Support -> validateSupport(order, gameState, mapDefinition)
            is Order.Retreat -> validateRetreat(order, gameState, mapDefinition)
            is Order.Build -> validateBuild(order, gameState, mapDefinition)
            is Order.Hold -> valid(order)
            is Order.Convoy -> valid(order) // convoy syntactic checks are sufficient
            is Order.Disband -> valid(order)
            is Order.Waive -> valid(order)
        }
    }

    private fun validateMove(
        order: Order.Move,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        val unit = findUnit(order, gameState) ?: return invalid(order, "VOID: Unit not found")
        val destTerritory = mapDefinition.territories[order.destination]
            ?: return invalid(order, "VOID: Unknown territory")

        // Army cannot enter sea zone
        if (unit.type == UnitType.ARMY && destTerritory.type == TerritoryType.SEA) {
            return invalidToHold(order, "VOID: Army cannot enter sea zone")
        }

        // Fleet cannot enter inland
        if (unit.type == UnitType.FLEET && destTerritory.type == TerritoryType.LAND) {
            return invalidToHold(order, "VOID: Fleet cannot enter inland")
        }

        // Check adjacency (unless via convoy)
        if (!order.viaConvoy) {
            if (!mapDefinition.isAdjacent(order.unitTerritory, order.destination, unit.type)) {
                return invalidToHold(order, "VOID: Unreachable destination")
            }
        }

        return valid(order)
    }

    private fun validateSupport(
        order: Order.Support,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        val supportingUnit = findUnit(order, gameState)
            ?: return invalid(order, "VOID: Unit not found")

        // The supporting unit must be able to legally move to the supported destination
        val destination = order.supportedDestination ?: order.supportedUnit
        val destTerritory = mapDefinition.territories[destination]

        // Check terrain compatibility
        if (destTerritory != null) {
            if (supportingUnit.type == UnitType.ARMY && destTerritory.type == TerritoryType.SEA) {
                return invalidToHold(order, "VOID: Cannot support unreachable territory")
            }
            if (supportingUnit.type == UnitType.FLEET && destTerritory.type == TerritoryType.LAND) {
                return invalidToHold(order, "VOID: Cannot support unreachable territory")
            }
        }

        // For support-move: supporting unit must be adjacent to the destination
        // For support-hold: supporting unit must be adjacent to the supported unit's territory
        // Note: for multi-coast, support doesn't need to specify coast — check parent adjacency
        val effectiveDestination = if (destTerritory?.parentTerritory != null) {
            destTerritory.parentTerritory
        } else {
            destination
        }

        if (!mapDefinition.isAdjacent(order.unitTerritory, effectiveDestination, supportingUnit.type)) {
            // Also check if adjacent to the exact territory (for coast-specific adjacencies)
            if (!mapDefinition.isAdjacent(order.unitTerritory, destination, supportingUnit.type)) {
                return invalidToHold(order, "VOID: Cannot support unreachable territory")
            }
        }

        return valid(order)
    }

    private fun validateRetreat(
        order: Order.Retreat,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        val dislodged = gameState.dislodgedUnits.find {
            it.unit.territoryId == order.unitTerritory && it.unit.power == order.power
        } ?: return invalid(order, "VOID: Unit not found")

        val destTerritory = mapDefinition.territories[order.destination]
            ?: return invalid(order, "VOID: Unknown territory")

        // Cannot retreat to sea if army
        if (dislodged.unit.type == UnitType.ARMY && destTerritory.type == TerritoryType.SEA) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        // Cannot retreat to inland if fleet
        if (dislodged.unit.type == UnitType.FLEET && destTerritory.type == TerritoryType.LAND) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        // Must be adjacent
        if (!mapDefinition.isAdjacent(order.unitTerritory, order.destination, dislodged.unit.type)) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        // Cannot retreat to the territory from which the attacker came
        if (order.destination == dislodged.attackedFrom) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        // Cannot retreat to an occupied territory
        if (gameState.units.any { it.territoryId == order.destination }) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        // Cannot retreat to a standoff territory
        if (order.destination in gameState.standoffTerritories) {
            return invalidToDisband(order, "VOID: No valid retreat")
        }

        return valid(order)
    }

    private fun validateBuild(
        order: Order.Build,
        gameState: GameState,
        mapDefinition: MapDefinition
    ): ValidationResult {
        val territory = mapDefinition.territories[order.unitTerritory]
            ?: return invalid(order, "VOID: Cannot build there")

        // Must be a home supply center for this power
        val effectiveTerritory = if (territory.parentTerritory != null) {
            mapDefinition.territories[territory.parentTerritory]
        } else {
            territory
        }

        if (effectiveTerritory == null || effectiveTerritory.homeCenter != order.power) {
            return invalid(order, "VOID: Cannot build there")
        }

        if (!effectiveTerritory.isSupplyCenter) {
            return invalid(order, "VOID: Cannot build there")
        }

        // Must be unoccupied
        val occupiedId = effectiveTerritory.id
        val isOccupied = gameState.units.any { unit ->
            unit.territoryId == occupiedId ||
                (effectiveTerritory.coasts.isNotEmpty() && unit.territoryId in effectiveTerritory.coasts)
        }
        if (isOccupied) {
            return invalid(order, "VOID: Cannot build there")
        }

        // Must be owned by the power
        if (gameState.supplyCenterOwnership[occupiedId] != order.power) {
            return invalid(order, "VOID: Cannot build there")
        }

        // Fleet cannot be built on inland territory
        if (order.unitType == UnitType.FLEET && effectiveTerritory.type == TerritoryType.LAND) {
            return invalid(order, "VOID: Cannot build there")
        }

        // Fleet on multi-coast territory must specify coast
        if (order.unitType == UnitType.FLEET && effectiveTerritory.coasts.isNotEmpty()) {
            if (order.coast == null && order.unitTerritory == effectiveTerritory.id) {
                return invalid(order, "VOID: Must specify coast")
            }
        }

        return valid(order)
    }

    // ================================================================
    // PHASE VALIDATION
    // ================================================================

    private fun validatePhase(order: Order, phase: Phase): ValidationResult? {
        val validForPhase = when (phase) {
            Phase.DIPLOMACY, Phase.ORDER_SUBMISSION -> order is Order.Hold || order is Order.Move ||
                order is Order.Support || order is Order.Convoy
            Phase.RETREAT -> order is Order.Retreat || order is Order.Disband
            Phase.BUILD -> order is Order.Build || order is Order.Disband || order is Order.Waive
        }
        if (!validForPhase) {
            return invalid(order, "VOID: Invalid order type for phase")
        }
        return null
    }

    // ================================================================
    // HELPERS
    // ================================================================

    private fun findUnit(order: Order, gameState: GameState): MapUnit? =
        gameState.units.find { it.territoryId == order.unitTerritory && it.power == order.power }

    private fun valid(order: Order) = ValidationResult(order, true)

    private fun invalid(order: Order, errorCode: String) =
        ValidationResult(order, false, errorCode)

    private fun invalidToHold(order: Order, errorCode: String) =
        ValidationResult(
            order, false, errorCode,
            fallbackOrder = Order.Hold(order.power, order.unitTerritory)
        )

    private fun invalidToDisband(order: Order.Retreat, errorCode: String) =
        ValidationResult(
            order, false, errorCode,
            fallbackOrder = Order.Disband(order.power, order.unitTerritory)
        )
}
