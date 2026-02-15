package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * DATC Section 6.F — Retreat phase tests.
 */
class RetreatResolverTest {

    private val map = ClassicMap.definition
    private val resolver = RetreatResolver(map)

    private fun retreatState(
        units: List<MapUnit> = emptyList(),
        dislodgedUnits: List<DislodgedUnit>,
        standoffTerritories: Set<String> = emptySet()
    ) = GameState(
        phase = Phase.RETREAT,
        year = 1901,
        season = Season.SPRING,
        units = units,
        supplyCenterOwnership = emptyMap(),
        dislodgedUnits = dislodgedUnits,
        standoffTerritories = standoffTerritories
    )

    private fun outcome(result: AdjudicationResult, territory: String): OrderOutcome =
        result.resolvedOrders.first { it.order.unitTerritory == territory }.outcome

    @Nested
    inner class BasicRetreats {

        @Test
        fun `6_F_1 - retreat to adjacent empty territory succeeds`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertTrue(result.newGameState.units.any { it.territoryId == "SIL" && it.power == Power.GERMANY })
        }

        @Test
        fun `6_F_2 - retreat to attacker origin fails`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "BER", "MUN"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.FAILED, outcome(result, "BER"))
        }

        @Test
        fun `6_F_3 - retreat to occupied territory fails`() {
            val gs = retreatState(
                units = listOf(MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL")),
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.FAILED, outcome(result, "BER"))
        }

        @Test
        fun `6_F_4 - retreat to standoff territory fails`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                ),
                standoffTerritories = setOf("SIL")
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.FAILED, outcome(result, "BER"))
        }

        @Test
        fun `6_F_5 - retreat to non-adjacent territory fails`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "BER", "GAL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.FAILED, outcome(result, "BER"))
        }
    }

    @Nested
    inner class RetreatConflicts {

        @Test
        fun `6_F_6 - two units retreating to same territory both disband`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN"),
                    DislodgedUnit(MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"), "MOS")
                )
            )
            val orders = listOf(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                Order.Retreat(Power.RUSSIA, "WAR", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
            // Neither unit should appear in new game state
            assertTrue(result.newGameState.units.none { it.territoryId == "SIL" })
        }

        @Test
        fun `6_F_7 - one retreat succeeds while different retreat conflicts`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN"),
                    DislodgedUnit(MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"), "MOS"),
                    DislodgedUnit(MapUnit(Power.AUSTRIA, UnitType.ARMY, "BOH"), "VIE")
                )
            )
            val orders = listOf(
                Order.Retreat(Power.GERMANY, "BER", "PRU"),    // succeeds - no conflict
                Order.Retreat(Power.RUSSIA, "WAR", "SIL"),     // conflicts
                Order.Retreat(Power.AUSTRIA, "BOH", "SIL")     // conflicts
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BOH"))
            assertTrue(result.newGameState.units.any { it.territoryId == "PRU" && it.power == Power.GERMANY })
        }
    }

    @Nested
    inner class DisbandAndAutoDisband {

        @Test
        fun `6_F_8 - explicit disband succeeds`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val orders = listOf(Order.Disband(Power.GERMANY, "BER"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertTrue(result.newGameState.units.none { it.power == Power.GERMANY && it.territoryId == "BER" })
        }

        @Test
        fun `6_F_9 - unit with no order is auto-disbanded`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val result = resolver.resolve(gs, emptyList())

            assertEquals(1, result.resolvedOrders.size)
            assertEquals(OrderOutcome.SUCCEEDED, result.resolvedOrders[0].outcome)
            assertTrue(result.resolvedOrders[0].reason!!.contains("Auto-disbanded"))
        }
    }

    @Nested
    inner class FleetRetreats {

        @Test
        fun `6_F_10 - fleet retreats to adjacent sea zone`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"), "NWG")
                )
            )
            val orders = listOf(Order.Retreat(Power.ENGLAND, "NTH", "ENG"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "NTH"))
            assertTrue(result.newGameState.units.any { it.territoryId == "ENG" })
        }

        @Test
        fun `6_F_11 - fleet cannot retreat to inland territory`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.FLEET, "KIE"), "HOL")
                )
            )
            val orders = listOf(Order.Retreat(Power.GERMANY, "KIE", "MUN"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.FAILED, outcome(result, "KIE"))
        }
    }

    @Nested
    inner class PhaseTransition {

        @Test
        fun `retreat in spring transitions to fall order submission`() {
            val gs = retreatState(
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val result = resolver.resolve(gs, listOf(Order.Retreat(Power.GERMANY, "BER", "SIL")))

            assertEquals(Phase.ORDER_SUBMISSION, result.nextPhase)
            assertEquals(Season.FALL, result.newGameState.season)
        }

        @Test
        fun `retreat in fall transitions to build phase`() {
            val gs = GameState(
                phase = Phase.RETREAT,
                year = 1901,
                season = Season.FALL,
                units = emptyList(),
                supplyCenterOwnership = emptyMap(),
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val result = resolver.resolve(gs, listOf(Order.Disband(Power.GERMANY, "BER")))

            assertEquals(Phase.BUILD, result.nextPhase)
        }
    }
}
