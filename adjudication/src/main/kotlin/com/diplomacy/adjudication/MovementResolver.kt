package com.diplomacy.adjudication

/**
 * Core movement resolution engine implementing Kruijswijk's algorithm.
 * Handles DATC 6.A (basic moves) and 6.C (circular movement).
 *
 * The algorithm:
 * 1. Build a resolution state for each order
 * 2. Iteratively resolve orders until no more can be resolved
 * 3. Handle circular moves (rotations succeed)
 * 4. Apply results to produce new game state
 */
class MovementResolver(private val mapDefinition: MapDefinition) {

    fun resolve(gameState: GameState, orders: List<Order>): AdjudicationResult {
        // Validate and normalize orders: unordered units default to Hold
        val allOrders = addDefaultHolds(gameState, orders)

        val context = ResolutionContext(gameState, allOrders, mapDefinition)
        context.resolve()

        return context.buildResult()
    }
}

internal class ResolutionContext(
    private val gameState: GameState,
    private val orders: List<Order>,
    private val mapDefinition: MapDefinition
) {
    // Resolution state for each order
    private val states = mutableMapOf<String, OrderState>()

    // Territory -> the order for the unit in that territory
    private val orderByTerritory = mutableMapOf<String, Order>()

    // Territory -> list of move orders targeting it
    private val movesTo = mutableMapOf<String, MutableList<Order.Move>>()

    init {
        for (order in orders) {
            val key = order.unitTerritory
            orderByTerritory[key] = order
            states[key] = OrderState(order)

            if (order is Order.Move) {
                movesTo.getOrPut(order.destination) { mutableListOf() }.add(order)
            }
        }
    }

    fun resolve() {
        // Iterative resolution: keep resolving until no progress
        var changed = true
        while (changed) {
            changed = false
            for ((_, state) in states) {
                if (state.resolved) continue
                if (tryResolve(state)) {
                    changed = true
                }
            }
        }

        // Any remaining unresolved moves are part of cycles — resolve as successful rotations
        resolveCircularMoves()

        // Any still unresolved (shouldn't happen) default to failed
        for ((_, state) in states) {
            if (!state.resolved) {
                state.outcome = OrderOutcome.FAILED
                state.resolved = true
                state.reason = "Unresolvable"
            }
        }
    }

    private fun tryResolve(state: OrderState): Boolean {
        return when (state.order) {
            is Order.Hold -> resolveHold(state)
            is Order.Move -> resolveMove(state)
            is Order.Support -> resolveSupport(state)
            is Order.Convoy -> resolveConvoy(state)
            else -> {
                state.outcome = OrderOutcome.SUCCEEDED
                state.resolved = true
                true
            }
        }
    }

    // ================================================================
    // HOLD RESOLUTION
    // ================================================================

    private fun resolveHold(state: OrderState): Boolean {
        // A hold always succeeds (unit stays in place).
        // Whether it gets dislodged is determined by attacking moves.
        state.outcome = OrderOutcome.SUCCEEDED
        state.resolved = true
        return true
    }

    // ================================================================
    // MOVE RESOLUTION
    // ================================================================

    private fun resolveMove(state: OrderState): Boolean {
        val move = state.order as Order.Move
        val destination = move.destination

        // For convoy moves, check if convoy chain exists
        if (move.viaConvoy) {
            val convoyFleets = ConvoyPathFinder.findConvoyFleets(
                move.unitTerritory, move.destination, orders, mapDefinition
            )

            // Check if convoy fleets are resolved
            val disruptedFleets = mutableSetOf<String>()
            for (fleetTerritory in convoyFleets) {
                val fleetState = states[fleetTerritory]
                if (fleetState != null) {
                    if (!fleetState.resolved) return false // wait for convoy fleet resolution
                    if (fleetState.outcome == OrderOutcome.DISRUPTED || fleetState.outcome == OrderOutcome.DISLODGED) {
                        disruptedFleets.add(fleetTerritory)
                    }
                }
            }

            val hasPath = ConvoyPathFinder.hasPath(
                move.unitTerritory, move.destination, convoyFleets, disruptedFleets, mapDefinition
            )
            if (!hasPath) {
                // Convoy chain broken — move fails, apply Szykman's Rule:
                // convoyed army holds in place
                state.outcome = OrderOutcome.BOUNCED
                state.resolved = true
                state.reason = "Convoy chain disrupted"
                return true
            }
        }

        // Calculate attack strength
        val attackStrength = calculateAttackStrength(move)
        if (attackStrength < 0) return false // supports not yet resolved

        // Check for head-to-head battle
        val headToHead = findHeadToHead(move)
        if (headToHead != null) {
            return resolveHeadToHead(state, move, headToHead)
        }

        // Check competing moves to same destination
        val competingMoves = movesTo[destination]?.filter { it.unitTerritory != move.unitTerritory } ?: emptyList()

        // Get defense strength of destination
        val defenseStrength = calculateDefenseStrength(destination, move)
        if (defenseStrength < 0) return false // not yet resolved

        // Get competing attack strengths
        for (competing in competingMoves) {
            val compStr = calculateAttackStrength(competing)
            if (compStr < 0) return false // not yet resolved
        }

        // Now we can resolve
        val maxCompetingAttack = competingMoves.maxOfOrNull { calculateAttackStrength(it) } ?: 0

        if (attackStrength > defenseStrength && attackStrength > maxCompetingAttack) {
            // Check self-dislodgement: a power cannot dislodge its own unit
            val defenderOrder = orderByTerritory[destination]
            if (defenderOrder != null) {
                val defenderState = states[destination]!!
                val defenderUnit = gameState.units.find { it.territoryId == destination }
                val isOwnUnit = defenderUnit?.power == move.power
                val defenderStaying = defenderOrder !is Order.Move ||
                    (defenderState.resolved && defenderState.outcome != OrderOutcome.SUCCEEDED)

                if (isOwnUnit && defenderStaying) {
                    // Cannot dislodge own unit — bounce
                    state.outcome = OrderOutcome.BOUNCED
                    state.resolved = true
                    state.reason = "Cannot dislodge own unit"
                    return true
                }
            }

            // Move succeeds
            state.outcome = OrderOutcome.SUCCEEDED
            state.resolved = true

            // Dislodge the unit at destination (if any and not moving away)
            if (defenderOrder != null) {
                val defenderState = states[destination]!!
                if (defenderOrder !is Order.Move || !defenderState.resolved || defenderState.outcome != OrderOutcome.SUCCEEDED) {
                    defenderState.outcome = OrderOutcome.DISLODGED
                    defenderState.resolved = true
                    defenderState.reason = "Dislodged by ${move.power} from ${move.unitTerritory}"
                }
            }

            // Competing moves bounce
            for (competing in competingMoves) {
                val compState = states[competing.unitTerritory]!!
                if (!compState.resolved) {
                    compState.outcome = OrderOutcome.BOUNCED
                    compState.resolved = true
                    compState.reason = "Bounced with ${move.power} from ${move.unitTerritory}"
                }
            }

            return true
        } else if (attackStrength <= maxCompetingAttack || attackStrength <= defenseStrength) {
            // All competing moves to this destination bounce (including this one)
            // But only if all can be resolved

            // This move bounces
            state.outcome = OrderOutcome.BOUNCED
            state.resolved = true
            if (attackStrength <= defenseStrength) {
                state.reason = "Bounced: insufficient strength against defender"
            } else {
                state.reason = "Bounced: standoff with equal attack"
            }

            // If all competing are equal strength, they all bounce too
            if (attackStrength == maxCompetingAttack) {
                for (competing in competingMoves) {
                    val compState = states[competing.unitTerritory]!!
                    if (!compState.resolved) {
                        val compAttack = calculateAttackStrength(competing)
                        if (compAttack <= attackStrength) {
                            compState.outcome = OrderOutcome.BOUNCED
                            compState.resolved = true
                            compState.reason = "Bounced: standoff"
                        }
                    }
                }
            }
            return true
        }

        return false
    }

    // ================================================================
    // HEAD-TO-HEAD BATTLES
    // ================================================================

    private fun findHeadToHead(move: Order.Move): Order.Move? {
        val oppositeOrder = orderByTerritory[move.destination]
        if (oppositeOrder is Order.Move && oppositeOrder.destination == move.unitTerritory) {
            return oppositeOrder
        }
        return null
    }

    private fun resolveHeadToHead(
        state: OrderState,
        move: Order.Move,
        opponent: Order.Move
    ): Boolean {
        val myStrength = calculateAttackStrength(move)
        val oppStrength = calculateAttackStrength(opponent)
        if (myStrength < 0 || oppStrength < 0) return false

        val oppState = states[opponent.unitTerritory]!!

        if (myStrength > oppStrength) {
            state.outcome = OrderOutcome.SUCCEEDED
            state.resolved = true
            oppState.outcome = OrderOutcome.BOUNCED
            oppState.resolved = true
            oppState.reason = "Lost head-to-head battle against ${move.power}"

            // The opponent is dislodged
            oppState.outcome = OrderOutcome.DISLODGED
            oppState.reason = "Dislodged in head-to-head by ${move.power} from ${move.unitTerritory}"
            return true
        } else if (oppStrength > myStrength) {
            state.outcome = OrderOutcome.BOUNCED
            state.resolved = true
            state.reason = "Lost head-to-head battle against ${opponent.power}"

            oppState.outcome = OrderOutcome.SUCCEEDED
            oppState.resolved = true

            // This unit is dislodged
            state.outcome = OrderOutcome.DISLODGED
            state.reason = "Dislodged in head-to-head by ${opponent.power} from ${opponent.unitTerritory}"
            return true
        } else {
            // Equal strength: both bounce
            state.outcome = OrderOutcome.BOUNCED
            state.resolved = true
            state.reason = "Head-to-head standoff"

            oppState.outcome = OrderOutcome.BOUNCED
            oppState.resolved = true
            oppState.reason = "Head-to-head standoff"
            return true
        }
    }

    // ================================================================
    // SUPPORT RESOLUTION
    // ================================================================

    private fun resolveSupport(state: OrderState): Boolean {
        val support = state.order as Order.Support
        val territory = support.unitTerritory

        // Check if support is cut by an attack from a non-destination territory
        val destination = support.supportedDestination ?: support.supportedUnit
        val attacksOnSupporter = movesTo[territory] ?: emptyList()

        for (attack in attacksOnSupporter) {
            // Support is NOT cut by attacks from the destination territory
            if (attack.unitTerritory == destination) continue
            // Support IS cut by attacks from any other territory
            // (even if the attack will eventually bounce)
            state.outcome = OrderOutcome.CUT
            state.resolved = true
            state.reason = "Support cut by ${attack.power} from ${attack.unitTerritory}"
            return true
        }

        state.outcome = OrderOutcome.SUCCEEDED
        state.resolved = true
        return true
    }

    // ================================================================
    // CONVOY RESOLUTION
    // ================================================================

    private fun resolveConvoy(state: OrderState): Boolean {
        // For now, convoy succeeds unless the fleet is dislodged
        // (Full convoy logic in E3-S5)
        val convoy = state.order as Order.Convoy
        val territory = convoy.unitTerritory

        // Check if fleet is being attacked
        val attacks = movesTo[territory] ?: emptyList()
        if (attacks.isEmpty()) {
            state.outcome = OrderOutcome.SUCCEEDED
            state.resolved = true
            return true
        }

        // If fleet is being attacked, we need to wait for those attacks to resolve
        val allAttacksResolved = attacks.all { states[it.unitTerritory]?.resolved == true }
        if (!allAttacksResolved) return false

        // Check if any attack succeeded (fleet would be dislodged)
        val dislodged = attacks.any { states[it.unitTerritory]?.outcome == OrderOutcome.SUCCEEDED }
        if (dislodged) {
            state.outcome = OrderOutcome.DISRUPTED
            state.resolved = true
            state.reason = "Convoy disrupted: fleet dislodged"
        } else {
            state.outcome = OrderOutcome.SUCCEEDED
            state.resolved = true
        }
        return true
    }

    // ================================================================
    // STRENGTH CALCULATION
    // ================================================================

    /**
     * Returns the attack strength of a move order, or -1 if supports aren't resolved yet.
     */
    internal fun calculateAttackStrength(move: Order.Move): Int {
        var strength = 1 // base strength

        // Find supports for this move
        for ((_, state) in states) {
            if (state.order is Order.Support) {
                val support = state.order
                if (support.supportedUnit == move.unitTerritory &&
                    support.supportedDestination == move.destination
                ) {
                    if (!state.resolved) return -1 // not yet resolved
                    if (state.outcome == OrderOutcome.SUCCEEDED) {
                        strength++
                    }
                }
            }
        }

        return strength
    }

    /**
     * Returns the defense strength of a territory against a specific attacker,
     * or -1 if not yet resolvable.
     */
    private fun calculateDefenseStrength(territory: String, attacker: Order.Move): Int {
        val defenderOrder = orderByTerritory[territory] ?: return 0

        // If defender is moving away, defense is 0 (unless move fails)
        if (defenderOrder is Order.Move) {
            val defState = states[territory]!!
            if (!defState.resolved) return -1
            if (defState.outcome == OrderOutcome.SUCCEEDED) return 0
        }

        var strength = 1 // base defense

        // Add supports for holding
        for ((_, state) in states) {
            if (state.order is Order.Support) {
                val support = state.order
                if (support.supportedUnit == territory && support.supportedDestination == null) {
                    // Support to hold
                    if (!state.resolved) return -1
                    if (state.outcome == OrderOutcome.SUCCEEDED) {
                        // Support from the attacker's power to the defender doesn't count
                        // (you can't support your own attack target's defense)
                        strength++
                    }
                }
            }
        }

        return strength
    }

    // ================================================================
    // CIRCULAR MOVE RESOLUTION
    // ================================================================

    /**
     * Unresolved moves at this point form circular chains (A→B→C→A).
     * Per Diplomacy rules, all moves in a rotation succeed simultaneously.
     */
    private fun resolveCircularMoves() {
        val unresolvedMoves = states.values.filter {
            !it.resolved && it.order is Order.Move
        }

        if (unresolvedMoves.isEmpty()) return

        // Find cycles among unresolved moves
        val visited = mutableSetOf<String>()

        for (state in unresolvedMoves) {
            if (state.order.unitTerritory in visited) continue

            val cycle = findCycle(state.order.unitTerritory, visited)
            if (cycle != null) {
                // All moves in the cycle succeed
                for (territory in cycle) {
                    val s = states[territory]!!
                    s.outcome = OrderOutcome.SUCCEEDED
                    s.resolved = true
                }
            }
        }
    }

    private fun findCycle(start: String, visited: MutableSet<String>): List<String>? {
        val path = mutableListOf<String>()
        var current = start

        while (current !in visited) {
            path.add(current)
            visited.add(current)

            val order = orderByTerritory[current]
            if (order !is Order.Move) return null

            val state = states[current]
            if (state == null || state.resolved) return null

            current = order.destination
        }

        // Check if we found a cycle (current is in our path)
        val cycleStart = path.indexOf(current)
        if (cycleStart >= 0) {
            return path.subList(cycleStart, path.size)
        }

        return null
    }

    // ================================================================
    // BUILD RESULT
    // ================================================================

    fun buildResult(): AdjudicationResult {
        val resolvedOrders = states.values.map { state ->
            ResolvedOrder(state.order, state.outcome, state.reason)
        }

        // Build new unit list
        val newUnits = mutableListOf<MapUnit>()
        val dislodgedUnits = mutableListOf<DislodgedUnit>()

        for (unit in gameState.units) {
            val state = states[unit.territoryId]

            if (state == null) {
                // No order for this unit, it stays
                newUnits.add(unit)
                continue
            }

            when (state.outcome) {
                OrderOutcome.SUCCEEDED -> {
                    if (state.order is Order.Move) {
                        // Unit moves to new territory
                        newUnits.add(unit.copy(territoryId = (state.order as Order.Move).destination))
                    } else {
                        // Unit stays
                        newUnits.add(unit)
                    }
                }
                OrderOutcome.DISLODGED -> {
                    // Find who dislodged this unit
                    val attacker = states.values.find {
                        it.order is Order.Move &&
                            (it.order as Order.Move).destination == unit.territoryId &&
                            it.outcome == OrderOutcome.SUCCEEDED
                    }
                    val attackedFrom = if (attacker != null) attacker.order.unitTerritory else ""
                    dislodgedUnits.add(DislodgedUnit(unit, attackedFrom))
                }
                else -> {
                    // Unit stays (bounced, failed, etc.)
                    newUnits.add(unit)
                }
            }
        }

        // Determine standoff territories (where moves bounced)
        val standoffTerritories = mutableSetOf<String>()
        for ((dest, moves) in movesTo) {
            if (moves.size >= 2 && moves.all { states[it.unitTerritory]?.outcome == OrderOutcome.BOUNCED }) {
                standoffTerritories.add(dest)
            }
        }

        // Determine supply center changes (only after Fall move phase)
        val scChanges = mutableListOf<SupplyCenterChange>()
        if (gameState.season == Season.FALL && gameState.phase == Phase.ORDER_SUBMISSION) {
            for (unit in newUnits) {
                val territory = mapDefinition.territories[unit.territoryId] ?: continue
                // Check parent territory for multi-coast
                val effectiveId = territory.parentTerritory ?: territory.id
                val effectiveTerritory = mapDefinition.territories[effectiveId] ?: continue
                if (effectiveTerritory.isSupplyCenter) {
                    val currentOwner = gameState.supplyCenterOwnership[effectiveId]
                    if (currentOwner != unit.power) {
                        scChanges.add(SupplyCenterChange(effectiveId, currentOwner, unit.power))
                    }
                }
            }
        }

        val newOwnership = gameState.supplyCenterOwnership.toMutableMap()
        for (change in scChanges) {
            newOwnership[change.territoryId] = change.newOwner
        }

        val nextPhase = if (dislodgedUnits.isNotEmpty()) Phase.RETREAT else {
            when (gameState.phase) {
                Phase.ORDER_SUBMISSION -> {
                    if (gameState.season == Season.FALL) Phase.BUILD
                    else Phase.ORDER_SUBMISSION // Spring → Fall (simplified)
                }
                else -> Phase.ORDER_SUBMISSION
            }
        }

        val nextSeason = if (gameState.phase == Phase.ORDER_SUBMISSION && gameState.season == Season.SPRING) {
            Season.FALL
        } else {
            gameState.season
        }

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
            supplyCenterOwnership = newOwnership,
            dislodgedUnits = dislodgedUnits,
            standoffTerritories = standoffTerritories
        )

        return AdjudicationResult(
            resolvedOrders = resolvedOrders,
            newGameState = newGameState,
            dislodgedUnits = dislodgedUnits,
            supplyCenterChanges = scChanges,
            nextPhase = nextPhase
        )
    }
}

/**
 * Adds default Hold orders for any units that don't have explicit orders.
 */
internal fun addDefaultHolds(gameState: GameState, orders: List<Order>): List<Order> {
    val orderedTerritories = orders.map { it.unitTerritory }.toSet()
    val defaultHolds = gameState.units
        .filter { it.territoryId !in orderedTerritories }
        .map { Order.Hold(it.power, it.territoryId) }
    return orders + defaultHolds
}

internal class OrderState(
    val order: Order,
    var outcome: OrderOutcome = OrderOutcome.SUCCEEDED,
    var resolved: Boolean = false,
    var reason: String? = null
)
