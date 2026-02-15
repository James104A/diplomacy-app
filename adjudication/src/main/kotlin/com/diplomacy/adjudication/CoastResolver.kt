package com.diplomacy.adjudication

/**
 * Handles multi-coast territory logic for fleet moves.
 * Three territories have multiple coasts: STP (NC/SC), SPA (NC/SC), BUL (EC/SC).
 *
 * Rules:
 * - Fleets moving to a multi-coast territory MUST specify which coast
 * - If only one coast is reachable from the origin, it can be auto-inferred
 * - Armies ignore coasts entirely (treat multi-coast as single territory)
 * - Support to a multi-coast territory doesn't require coast specification
 */
object CoastResolver {

    /**
     * Resolves the effective destination for a move order, handling coast inference.
     * Returns null if the coast cannot be determined (ambiguous).
     */
    fun resolveDestination(
        move: Order.Move,
        unitType: UnitType,
        mapDefinition: MapDefinition
    ): String? {
        if (unitType == UnitType.ARMY) {
            // Armies don't care about coasts
            return move.destination
        }

        val destTerritory = mapDefinition.territories[move.destination] ?: return move.destination

        // If destination is already a specific coast, use it directly
        if (destTerritory.parentTerritory != null) {
            return move.destination
        }

        // If destination has coasts, fleet must specify or auto-infer
        if (destTerritory.coasts.isNotEmpty()) {
            val reachableCoasts = mapDefinition.getReachableCoasts(move.unitTerritory, move.destination)
            return when {
                reachableCoasts.size == 1 -> reachableCoasts[0] // auto-infer
                reachableCoasts.isEmpty() -> null // no reachable coast
                else -> null // ambiguous — must specify
            }
        }

        return move.destination
    }

    /**
     * Checks if a fleet on a specific coast can reach the given destination.
     */
    fun canFleetReach(
        fromTerritory: String,
        destination: String,
        mapDefinition: MapDefinition
    ): Boolean {
        return mapDefinition.isAdjacent(fromTerritory, destination, UnitType.FLEET)
    }
}
