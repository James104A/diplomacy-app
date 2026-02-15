package com.diplomacy.adjudication

/**
 * Finds valid convoy paths from origin to destination via a chain of fleets in sea zones.
 * Used during movement resolution to validate convoy orders.
 */
object ConvoyPathFinder {

    /**
     * Returns true if there exists at least one valid convoy path from [origin] to [destination]
     * using the provided [convoyFleets] (territories containing fleets convoying this army).
     * [disruptedFleets] are fleets that have been dislodged and cannot convoy.
     */
    fun hasPath(
        origin: String,
        destination: String,
        convoyFleets: Set<String>,
        disruptedFleets: Set<String>,
        mapDefinition: MapDefinition
    ): Boolean {
        val activeFleets = convoyFleets - disruptedFleets
        if (activeFleets.isEmpty()) return false

        // BFS from origin through sea zones with active convoy fleets
        val visited = mutableSetOf<String>()
        val queue = ArrayDeque<String>()

        // Find sea zones adjacent to origin that have convoy fleets
        val originAdjacencies = mapDefinition.adjacenciesOf(origin)
        for (adj in originAdjacencies) {
            if (adj.targetId in activeFleets && UnitType.FLEET in adj.unitTypes) {
                queue.add(adj.targetId)
                visited.add(adj.targetId)
            }
        }

        while (queue.isNotEmpty()) {
            val current = queue.removeFirst()

            // Check if this sea zone is adjacent to destination
            val currentAdjacencies = mapDefinition.adjacenciesOf(current)
            for (adj in currentAdjacencies) {
                if (adj.targetId == destination) {
                    return true
                }
                // Continue through other fleet-occupied sea zones
                if (adj.targetId in activeFleets && adj.targetId !in visited && UnitType.FLEET in adj.unitTypes) {
                    visited.add(adj.targetId)
                    queue.add(adj.targetId)
                }
            }
        }

        return false
    }

    /**
     * Returns all fleets participating in any valid convoy path from [origin] to [destination].
     */
    fun findConvoyFleets(
        origin: String,
        destination: String,
        orders: List<Order>,
        mapDefinition: MapDefinition
    ): Set<String> {
        return orders.filterIsInstance<Order.Convoy>()
            .filter { it.convoyedArmy == origin && it.destination == destination }
            .map { it.unitTerritory }
            .toSet()
    }
}
