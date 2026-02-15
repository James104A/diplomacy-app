package com.diplomacy.adjudication

import org.junit.jupiter.api.RepeatedTest
import org.junit.jupiter.api.Test
import kotlin.random.Random
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Fuzz / stress tests for the adjudication engine.
 * Generates random orders and verifies invariants hold.
 */
class FuzzTest {

    private val adjudicator = Adjudicator()
    private val map = ClassicMap.definition

    @RepeatedTest(50)
    fun `random orders never crash the resolver`() {
        val gs = adjudicator.createInitialGameState()
        val orders = generateRandomOrders(gs, Random)
        val result = adjudicator.adjudicate(gs, orders)

        // Invariants that must always hold
        assertTrue(result.newGameState.units.isNotEmpty() || result.dislodgedUnits.isNotEmpty(),
            "Game must have units or dislodged units")
        assertTrue(result.resolvedOrders.isNotEmpty(), "Must have resolved orders")

        // No two units should occupy the same territory
        val territories = result.newGameState.units.map { it.territoryId }
        assertEquals(territories.size, territories.toSet().size,
            "Duplicate unit positions: $territories")
    }

    @RepeatedTest(20)
    fun `random multi-turn game maintains invariants`() {
        var gs = adjudicator.createInitialGameState()

        repeat(4) { turn ->
            val orders = generateRandomOrders(gs, Random)
            val result = adjudicator.adjudicate(gs, orders)

            // No duplicate positions
            val territories = result.newGameState.units.map { it.territoryId }
            assertEquals(territories.size, territories.toSet().size,
                "Turn $turn: duplicate positions")

            // Total units should not increase without builds
            if (gs.phase != Phase.BUILD) {
                assertTrue(result.newGameState.units.size <= gs.units.size + result.dislodgedUnits.size,
                    "Turn $turn: units appeared from nowhere")
            }

            gs = result.newGameState
        }
    }

    @Test
    fun `all powers submitting holds produces no changes`() {
        val gs = adjudicator.createInitialGameState()
        val orders = gs.units.map { Order.Hold(it.power, it.territoryId) }
        val result = adjudicator.adjudicate(gs, orders)

        assertEquals(22, result.newGameState.units.size)
        assertTrue(result.dislodgedUnits.isEmpty())
        for (unit in gs.units) {
            assertTrue(result.newGameState.units.any {
                it.territoryId == unit.territoryId && it.power == unit.power && it.type == unit.type
            })
        }
    }

    private fun generateRandomOrders(gs: GameState, random: Random): List<Order> {
        return gs.units.mapNotNull { unit ->
            when (gs.phase) {
                Phase.ORDER_SUBMISSION, Phase.DIPLOMACY -> generateMovementOrder(unit, random)
                Phase.RETREAT -> null // would need dislodged units
                Phase.BUILD -> null
            }
        }
    }

    private fun generateMovementOrder(unit: MapUnit, random: Random): Order {
        val adjacencies = map.adjacenciesOf(unit.territoryId)
            .filter { unit.type in it.unitTypes }

        if (adjacencies.isEmpty() || random.nextFloat() < 0.3f) {
            return Order.Hold(unit.power, unit.territoryId)
        }

        val dest = adjacencies[random.nextInt(adjacencies.size)]
        return Order.Move(unit.power, unit.territoryId, dest.targetId)
    }
}
