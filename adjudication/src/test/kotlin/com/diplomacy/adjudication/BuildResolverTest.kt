package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * DATC Section 6.G — Build/disband phase tests.
 */
class BuildResolverTest {

    private val map = ClassicMap.definition
    private val resolver = BuildResolver(map)

    private fun buildState(
        units: List<MapUnit> = emptyList(),
        ownership: Map<String, Power> = emptyMap()
    ) = GameState(
        phase = Phase.BUILD,
        year = 1902,
        season = Season.FALL,
        units = units,
        supplyCenterOwnership = ownership
    )

    private fun germanOwnership() = mapOf(
        "BER" to Power.GERMANY,
        "MUN" to Power.GERMANY,
        "KIE" to Power.GERMANY
    )

    private fun outcome(result: AdjudicationResult, territory: String): OrderOutcome =
        result.resolvedOrders.first { it.order.unitTerritory == territory }.outcome

    @Nested
    inner class BuildOrders {

        @Test
        fun `6_G_1 - build army on unoccupied home SC succeeds`() {
            val gs = buildState(
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "HOL"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BEL")
                ),
                ownership = germanOwnership() + mapOf(
                    "HOL" to Power.GERMANY,
                    "BEL" to Power.GERMANY
                )
            )
            // 5 SCs, 2 units → can build 3 (but only on home SCs: BER, MUN, KIE)
            val orders = listOf(Order.Build(Power.GERMANY, "BER", UnitType.ARMY))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertTrue(result.newGameState.units.any { it.territoryId == "BER" && it.type == UnitType.ARMY })
        }

        @Test
        fun `6_G_2 - build fleet on coastal home SC succeeds`() {
            val gs = buildState(
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "BER")),
                ownership = germanOwnership() + mapOf("HOL" to Power.GERMANY)
            )
            val orders = listOf(Order.Build(Power.GERMANY, "KIE", UnitType.FLEET))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "KIE"))
            assertTrue(result.newGameState.units.any { it.territoryId == "KIE" && it.type == UnitType.FLEET })
        }

        @Test
        fun `6_G_3 - build on non-home SC is rejected`() {
            val gs = buildState(
                units = emptyList(),
                ownership = mapOf("BEL" to Power.GERMANY) + germanOwnership()
            )
            val orders = listOf(Order.Build(Power.GERMANY, "BEL", UnitType.ARMY))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.VOID, outcome(result, "BEL"))
        }

        @Test
        fun `6_G_4 - build on occupied home SC is rejected`() {
            val gs = buildState(
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "BER")),
                ownership = germanOwnership() + mapOf("HOL" to Power.GERMANY)
            )
            val orders = listOf(Order.Build(Power.GERMANY, "BER", UnitType.ARMY))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.VOID, outcome(result, "BER"))
        }

        @Test
        fun `6_G_5 - build fleet on inland is rejected`() {
            val gs = buildState(
                units = emptyList(),
                ownership = germanOwnership() + mapOf("HOL" to Power.GERMANY)
            )
            val orders = listOf(Order.Build(Power.GERMANY, "MUN", UnitType.FLEET))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.VOID, outcome(result, "MUN"))
        }

        @Test
        fun `6_G_6 - cannot build more than adjustment allows`() {
            val gs = buildState(
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "HOL"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BEL")
                ),
                ownership = germanOwnership() // 3 SCs, 2 units → 1 build
            )
            val orders = listOf(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                Order.Build(Power.GERMANY, "MUN", UnitType.ARMY) // exceeds limit
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.VOID, outcome(result, "MUN"))
        }

        @Test
        fun `6_G_7 - waive order uses up a build slot`() {
            val gs = buildState(
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "HOL")),
                ownership = germanOwnership() // 3 SCs, 1 unit → 2 builds
            )
            val orders = listOf(
                Order.Waive(Power.GERMANY),
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                Order.Build(Power.GERMANY, "MUN", UnitType.ARMY) // third build, only 2 slots
            )
            val result = resolver.resolve(gs, orders)

            // Waive uses 1 slot, BER build uses 1 slot, MUN exceeds
            val waiveOutcome = result.resolvedOrders.first { it.order is Order.Waive }.outcome
            assertEquals(OrderOutcome.SUCCEEDED, waiveOutcome)
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.VOID, outcome(result, "MUN"))
        }

        @Test
        fun `6_G_8 - build on home SC not currently owned is rejected`() {
            val gs = buildState(
                units = emptyList(),
                ownership = mapOf(
                    "BER" to Power.RUSSIA, // Germany's home SC captured
                    "MUN" to Power.GERMANY,
                    "KIE" to Power.GERMANY,
                    "HOL" to Power.GERMANY
                )
            )
            val orders = listOf(Order.Build(Power.GERMANY, "BER", UnitType.ARMY))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.VOID, outcome(result, "BER"))
        }
    }

    @Nested
    inner class DisbandOrders {

        @Test
        fun `6_G_9 - explicit disband succeeds`() {
            val gs = buildState(
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "HOL"),
                    MapUnit(Power.GERMANY, UnitType.FLEET, "KIE")
                ),
                ownership = germanOwnership() // 3 SCs, 4 units → must disband 1
            )
            val orders = listOf(Order.Disband(Power.GERMANY, "HOL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "HOL"))
            assertTrue(result.newGameState.units.none { it.territoryId == "HOL" })
            assertEquals(3, result.newGameState.units.count { it.power == Power.GERMANY })
        }

        @Test
        fun `6_G_10 - auto-disband when no orders submitted`() {
            val gs = buildState(
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "HOL"),
                    MapUnit(Power.GERMANY, UnitType.FLEET, "KIE")
                ),
                ownership = germanOwnership() // 3 SCs, 4 units → must disband 1
            )
            val result = resolver.resolve(gs, emptyList())

            // One unit should be auto-disbanded
            assertEquals(3, result.newGameState.units.count { it.power == Power.GERMANY })
            assertTrue(result.resolvedOrders.any { it.reason?.contains("Auto-disbanded") == true })
        }

        @Test
        fun `6_G_11 - auto-disband prefers units not on home SCs`() {
            val gs = buildState(
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "HOL") // not home SC
                ),
                ownership = mapOf(
                    "BER" to Power.GERMANY,
                    "MUN" to Power.GERMANY
                ) // 2 SCs, 3 units → must disband 1
            )
            val result = resolver.resolve(gs, emptyList())

            assertEquals(2, result.newGameState.units.count { it.power == Power.GERMANY })
            // HOL (not a home SC) should be disbanded
            assertTrue(result.newGameState.units.none { it.territoryId == "HOL" })
        }
    }

    @Nested
    inner class MultiCoastBuilds {

        @Test
        fun `6_G_12 - build fleet on STP_SC succeeds`() {
            val gs = buildState(
                units = emptyList(),
                ownership = mapOf(
                    "STP" to Power.RUSSIA,
                    "MOS" to Power.RUSSIA,
                    "WAR" to Power.RUSSIA,
                    "SEV" to Power.RUSSIA
                )
            )
            val orders = listOf(Order.Build(Power.RUSSIA, "STP_SC", UnitType.FLEET))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "STP_SC"))
            assertTrue(result.newGameState.units.any { it.territoryId == "STP_SC" && it.type == UnitType.FLEET })
        }

        @Test
        fun `6_G_13 - build fleet on STP without coast is rejected`() {
            val gs = buildState(
                units = emptyList(),
                ownership = mapOf(
                    "STP" to Power.RUSSIA,
                    "MOS" to Power.RUSSIA,
                    "WAR" to Power.RUSSIA,
                    "SEV" to Power.RUSSIA
                )
            )
            val orders = listOf(Order.Build(Power.RUSSIA, "STP", UnitType.FLEET))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.VOID, outcome(result, "STP"))
        }

        @Test
        fun `6_G_14 - build army on STP without coast succeeds`() {
            val gs = buildState(
                units = emptyList(),
                ownership = mapOf(
                    "STP" to Power.RUSSIA,
                    "MOS" to Power.RUSSIA,
                    "WAR" to Power.RUSSIA,
                    "SEV" to Power.RUSSIA
                )
            )
            val orders = listOf(Order.Build(Power.RUSSIA, "STP", UnitType.ARMY))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "STP"))
        }
    }

    @Nested
    inner class PhaseTransition {

        @Test
        fun `build phase transitions to spring order submission`() {
            val gs = buildState(units = emptyList(), ownership = emptyMap())
            val result = resolver.resolve(gs, emptyList())

            assertEquals(Phase.ORDER_SUBMISSION, result.nextPhase)
            assertEquals(Season.SPRING, result.newGameState.season)
        }
    }
}
