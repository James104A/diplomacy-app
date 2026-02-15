package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * DATC Section 6.D — Support ordering tests.
 * Tests the nuances of support cutting, self-dislodgement prevention,
 * and various support edge cases.
 */
class SupportResolverTest {

    private val map = ClassicMap.definition
    private val resolver = MovementResolver(map)

    private fun gameState(units: List<MapUnit>) = GameState(
        phase = Phase.ORDER_SUBMISSION,
        year = 1901,
        season = Season.SPRING,
        units = units,
        supplyCenterOwnership = emptyMap()
    )

    private fun outcome(result: AdjudicationResult, territory: String): OrderOutcome =
        result.resolvedOrders.first { it.order.unitTerritory == territory }.outcome

    // ================================================================
    // 6.D.1–6.D.6: SUPPORT CUTTING RULES
    // ================================================================

    @Nested
    inner class SupportCutting {

        @Test
        fun `6_D_1 - support can be cut by unsupported attack`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Move(Power.RUSSIA, "BOH", "MUN") // cuts MUN's support
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.CUT, outcome(result, "MUN"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BOH"))
        }

        @Test
        fun `6_D_2 - support not cut by attack from destination`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "MUN") // from destination — does not cut
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN")) // support not cut
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
        }

        @Test
        fun `6_D_3 - support hold can be cut`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN")
                )
            )
            val orders = listOf(
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Support(Power.RUSSIA, "BOH", "SIL"), // support hold
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.GERMANY, "MUN", "BOH") // cuts the support hold
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.CUT, outcome(result, "BOH"))
            // Without support, SIL (str 1) vs BER (str 1) = bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
        }

        @Test
        fun `6_D_4 - support for move can be cut even if cutting attack bounces`() {
            // The attack on the supporting unit need not succeed to cut support
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "BOH")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Move(Power.AUSTRIA, "BOH", "MUN") // bounces but still cuts support
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.CUT, outcome(result, "MUN"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BOH"))
        }
    }

    // ================================================================
    // 6.D.7–6.D.12: SELF-DISLODGEMENT PREVENTION
    // ================================================================

    @Nested
    inner class SelfDislodgement {

        @Test
        fun `6_D_7 - a power cannot dislodge its own unit`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "SIL") // own unit
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Hold(Power.GERMANY, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            // Even with support, Germany cannot dislodge its own unit
            // This should be treated as a bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
        }

        @Test
        fun `6_D_8 - support does not count against own units`() {
            // Support from same power doesn't contribute to dislodging own unit
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "SIL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Move(Power.GERMANY, "SIL", "BOH")
            )
            val result = resolver.resolve(gs, orders)

            // SIL is moving away, so BER should succeed
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
        }
    }

    // ================================================================
    // 6.D.13–6.D.18: SUPPORT VARIATIONS
    // ================================================================

    @Nested
    inner class SupportVariations {

        @Test
        fun `6_D_13 - three-way standoff with support for one`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "BOH")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Move(Power.RUSSIA, "WAR", "SIL"),
                Order.Move(Power.AUSTRIA, "BOH", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            // Germany has strength 2, Russia and Austria have strength 1
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BOH"))
        }

        @Test
        fun `6_D_14 - mutual support in head-to-head`() {
            // Two pairs with mutual support
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "BER"),
                Order.Support(Power.RUSSIA, "WAR", "SIL", "BER")
            )
            val result = resolver.resolve(gs, orders)

            // Both have strength 2 — equal strength head-to-head = both bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "SIL"))
        }

        @Test
        fun `6_D_15 - multiple supports stack correctly`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "PRU"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Support(Power.GERMANY, "PRU", "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Support(Power.RUSSIA, "WAR", "SIL") // support hold
            )
            val result = resolver.resolve(gs, orders)

            // Germany: 1 + 2 = 3, Russia: 1 + 1 = 2 → Germany wins
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "SIL"))
        }

        @Test
        fun `6_D_16 - support for hold does not count against attacker from supported territory`() {
            // If A supports B hold, and B attacks A, the support is cut
            // (attack from the supported territory DOES cut support hold)
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH")
                )
            )
            val orders = listOf(
                Order.Support(Power.GERMANY, "MUN", "BOH"), // support hold for BOH
                Order.Move(Power.RUSSIA, "SIL", "MUN"),     // attack on supporter
                Order.Hold(Power.RUSSIA, "BOH")
            )
            val result = resolver.resolve(gs, orders)

            // SIL attacks MUN from a non-destination territory (BOH), so support is cut
            assertEquals(OrderOutcome.CUT, outcome(result, "MUN"))
        }
    }

    // ================================================================
    // 6.D.19–6.D.24: COMPLEX SUPPORT SCENARIOS
    // ================================================================

    @Nested
    inner class ComplexSupport {

        @Test
        fun `6_D_19 - support for move can be cut by dislodged unit`() {
            // Even a unit that will be dislodged can cut support before being dislodged
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "TYR"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "VIE")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Move(Power.RUSSIA, "BOH", "MUN"), // cuts MUN's support
                Order.Move(Power.AUSTRIA, "TYR", "BOH"),
                Order.Support(Power.AUSTRIA, "VIE", "TYR", "BOH")
            )
            val result = resolver.resolve(gs, orders)

            // BOH attacks MUN — cuts support even though BOH will be dislodged by TYR
            assertEquals(OrderOutcome.CUT, outcome(result, "MUN"))
            // Without support, BER (1) vs SIL (1) = bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            // TYR dislodges BOH
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "TYR"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "BOH"))
        }

        @Test
        fun `6_D_20 - support from multiple powers`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.AUSTRIA, "MUN", "BER", "SIL"), // Austria supports Germany
                Order.Hold(Power.RUSSIA, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            // Germany (2) vs Russia (1) → Germany wins
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "SIL"))
        }

        @Test
        fun `6_D_21 - double support vs double support - standoff`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "PRU"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "GAL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Support(Power.GERMANY, "PRU", "BER", "SIL"),
                Order.Move(Power.RUSSIA, "WAR", "SIL"),
                Order.Support(Power.RUSSIA, "BOH", "WAR", "SIL"),
                Order.Support(Power.RUSSIA, "GAL", "WAR", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            // Both have strength 3 → both bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
            assertTrue("SIL" in result.newGameState.standoffTerritories)
        }
    }
}
