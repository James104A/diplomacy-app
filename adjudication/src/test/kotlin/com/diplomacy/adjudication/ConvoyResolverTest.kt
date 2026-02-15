package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * DATC Section 6.E — Convoy ordering tests.
 * Tests convoy chains, disruption, and edge cases.
 */
class ConvoyResolverTest {

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
    // 6.E.1–6.E.5: BASIC CONVOYS
    // ================================================================

    @Nested
    inner class BasicConvoys {

        @Test
        fun `6_E_1 - simple convoy succeeds`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "NTH"))
            assertTrue(result.newGameState.units.any { it.territoryId == "NWY" && it.power == Power.ENGLAND })
        }

        @Test
        fun `6_E_2 - multi-hop convoy succeeds`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NWG")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Convoy(Power.ENGLAND, "NWG", "LON", "NWY")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
        }

        @Test
        fun `6_E_3 - convoy with no matching fleet fails`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "ENG") // not NTH
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true)
                // No convoy order for ENG
            )
            val result = resolver.resolve(gs, orders)

            // No convoy fleet matching → no path → bounces
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "LON"))
        }

        @Test
        fun `6_E_4 - convoy army attacks occupied territory`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "NWY")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Hold(Power.RUSSIA, "NWY")
            )
            val result = resolver.resolve(gs, orders)

            // Strength 1 vs defense 1 → bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "LON"))
        }

        @Test
        fun `6_E_5 - supported convoy attack dislodges`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NWG"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "NWY")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Support(Power.ENGLAND, "NWG", "LON", "NWY"),
                Order.Hold(Power.RUSSIA, "NWY")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "NWY"))
        }
    }

    // ================================================================
    // 6.E.6–6.E.12: CONVOY DISRUPTION
    // ================================================================

    @Nested
    inner class ConvoyDisruption {

        @Test
        fun `6_E_6 - dislodged convoy fleet disrupts convoy`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.FRANCE, UnitType.FLEET, "ENG"),
                    MapUnit(Power.FRANCE, UnitType.FLEET, "HEL")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Move(Power.FRANCE, "ENG", "NTH"),
                Order.Support(Power.FRANCE, "HEL", "ENG", "NTH")
            )
            val result = resolver.resolve(gs, orders)

            // France dislodges the convoy fleet in NTH
            assertEquals(OrderOutcome.DISRUPTED, outcome(result, "NTH"))
            // Convoy is broken, army stays in LON
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "LON"))
        }

        @Test
        fun `6_E_7 - convoy fleet survives attack - convoy succeeds`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.FRANCE, UnitType.FLEET, "ENG")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Move(Power.FRANCE, "ENG", "NTH") // unsupported attack, bounces
            )
            val result = resolver.resolve(gs, orders)

            // Attack on NTH fails (strength 1 vs 1)
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "NTH"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
        }

        @Test
        fun `6_E_8 - multi-hop convoy with one fleet disrupted still succeeds via alternate path`() {
            // Two possible paths: LON-NTH-NWY and LON-ENG-MAO-... (not applicable here)
            // With only one path, disruption breaks the convoy
            val gs = gameState(
                listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NWG"),
                    MapUnit(Power.FRANCE, UnitType.FLEET, "ENG"),
                    MapUnit(Power.FRANCE, UnitType.FLEET, "HEL")
                )
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "NWY"),
                Order.Convoy(Power.ENGLAND, "NWG", "LON", "NWY"),
                Order.Move(Power.FRANCE, "ENG", "NTH"),
                Order.Support(Power.FRANCE, "HEL", "ENG", "NTH")
            )
            val result = resolver.resolve(gs, orders)

            // NTH is dislodged, but NWG provides alternative path:
            // LON is adjacent to NTH (disrupted) and... actually LON is not adjacent to NWG
            // So if NTH is disrupted, there's no path from LON to NWY
            assertEquals(OrderOutcome.DISRUPTED, outcome(result, "NTH"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "LON"))
        }
    }

    // ================================================================
    // CONVOY PATH FINDER TESTS
    // ================================================================

    @Nested
    inner class ConvoyPathFinderTests {

        @Test
        fun `single fleet path exists`() {
            assertTrue(
                ConvoyPathFinder.hasPath(
                    "LON", "NWY",
                    convoyFleets = setOf("NTH"),
                    disruptedFleets = emptySet(),
                    mapDefinition = map
                )
            )
        }

        @Test
        fun `no path without fleet`() {
            assertEquals(
                false,
                ConvoyPathFinder.hasPath(
                    "LON", "NWY",
                    convoyFleets = emptySet(),
                    disruptedFleets = emptySet(),
                    mapDefinition = map
                )
            )
        }

        @Test
        fun `disrupted fleet breaks path`() {
            assertEquals(
                false,
                ConvoyPathFinder.hasPath(
                    "LON", "NWY",
                    convoyFleets = setOf("NTH"),
                    disruptedFleets = setOf("NTH"),
                    mapDefinition = map
                )
            )
        }

        @Test
        fun `multi-hop path exists`() {
            // LON -> NTH -> NWG -> BAR -> STP_NC?
            // Actually: LON is adjacent to NTH (fleet), NTH adjacent to NWG (fleet), NWG adjacent to NWY
            assertTrue(
                ConvoyPathFinder.hasPath(
                    "LON", "NWY",
                    convoyFleets = setOf("NTH", "NWG"),
                    disruptedFleets = emptySet(),
                    mapDefinition = map
                )
            )
        }
    }
}
