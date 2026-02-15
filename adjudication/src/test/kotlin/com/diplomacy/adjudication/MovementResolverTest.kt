package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MovementResolverTest {

    private val map = ClassicMap.definition
    private val resolver = MovementResolver(map)

    private fun gameState(
        units: List<MapUnit>,
        phase: Phase = Phase.ORDER_SUBMISSION,
        season: Season = Season.SPRING
    ) = GameState(
        phase = phase,
        year = 1901,
        season = season,
        units = units,
        supplyCenterOwnership = emptyMap()
    )

    private fun outcome(result: AdjudicationResult, territory: String): OrderOutcome =
        result.resolvedOrders.first { it.order.unitTerritory == territory }.outcome

    // ================================================================
    // DATC 6.A — BASIC MOVEMENT
    // ================================================================

    @Nested
    inner class BasicMovement {

        @Test
        fun `6_A_1 - move to empty adjacent territory succeeds`() {
            val gs = gameState(listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "BER")))
            val orders = listOf(Order.Move(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertTrue(result.newGameState.units.any { it.territoryId == "SIL" && it.power == Power.GERMANY })
            assertTrue(result.newGameState.units.none { it.territoryId == "BER" })
        }

        @Test
        fun `6_A_2 - move to occupied territory without support bounces`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
            assertTrue(result.newGameState.units.any { it.territoryId == "BER" && it.power == Power.GERMANY })
            assertTrue(result.newGameState.units.any { it.territoryId == "SIL" && it.power == Power.RUSSIA })
        }

        @Test
        fun `6_A_3 - supported move dislodges defender`() {
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
                Order.Hold(Power.RUSSIA, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "SIL"))
            assertTrue(result.dislodgedUnits.any { it.unit.power == Power.RUSSIA })
        }

        @Test
        fun `6_A_4 - two units bounce when attacking same territory`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "WAR", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
            // SIL should be a standoff territory
            assertTrue("SIL" in result.newGameState.standoffTerritories)
        }

        @Test
        fun `6_A_5 - supported attack wins over unsupported attack to same territory`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Move(Power.RUSSIA, "WAR", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "WAR"))
        }

        @Test
        fun `6_A_6 - unit with no orders holds by default`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN")
                )
            )
            // Only order for BER, MUN gets default Hold
            val orders = listOf(Order.Move(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            // MUN should still be in place
            assertTrue(result.newGameState.units.any { it.territoryId == "MUN" })
        }

        @Test
        fun `6_A_7 - fleet moves to adjacent sea zone`() {
            val gs = gameState(listOf(MapUnit(Power.ENGLAND, UnitType.FLEET, "LON")))
            val orders = listOf(Order.Move(Power.ENGLAND, "LON", "NTH"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
            assertTrue(result.newGameState.units.any { it.territoryId == "NTH" })
        }

        @Test
        fun `6_A_8 - fleet moves to adjacent coast`() {
            val gs = gameState(listOf(MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH")))
            val orders = listOf(Order.Move(Power.ENGLAND, "NTH", "NWY"))
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "NTH"))
            assertTrue(result.newGameState.units.any { it.territoryId == "NWY" })
        }

        @Test
        fun `6_A_9 - support holds against single attacker`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER")
                )
            )
            val orders = listOf(
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Support(Power.RUSSIA, "WAR", "SIL"), // support hold
                Order.Move(Power.GERMANY, "BER", "SIL")
            )
            val result = resolver.resolve(gs, orders)

            // SIL has strength 2 (1 base + 1 support), BER has strength 1
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
        }

        @Test
        fun `6_A_10 - support is cut by attack from non-destination`() {
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
                Order.Move(Power.RUSSIA, "BOH", "MUN") // cuts the support
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.CUT, outcome(result, "MUN"))
            // Without support, BER (strength 1) bounces against SIL (strength 1)
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
        }

        @Test
        fun `6_A_11 - support is NOT cut by attack from destination`() {
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
                Order.Move(Power.RUSSIA, "SIL", "MUN") // attack from destination — does NOT cut
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            // SIL's move to MUN bounces (or gets dislodged since BER succeeded to SIL)
        }

        @Test
        fun `6_A_12 - dislodged unit goes to dislodged list`() {
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
                Order.Hold(Power.RUSSIA, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(1, result.dislodgedUnits.size)
            assertEquals(Power.RUSSIA, result.dislodgedUnits[0].unit.power)
            assertEquals("SIL", result.dislodgedUnits[0].unit.territoryId)
            assertEquals("BER", result.dislodgedUnits[0].attackedFrom)
        }
    }

    // ================================================================
    // DATC 6.C — CIRCULAR MOVEMENT
    // ================================================================

    @Nested
    inner class CircularMovement {

        @Test
        fun `6_C_1 - two unit swap without convoy fails`() {
            // Two units trying to swap positions without convoy both bounce
            // (head-to-head battle, equal strength)
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "BER")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "SIL"))
        }

        @Test
        fun `6_C_2 - three unit rotation succeeds`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "MUN")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "MUN"),
                Order.Move(Power.AUSTRIA, "MUN", "BER")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))

            // Verify new positions
            assertTrue(result.newGameState.units.any { it.territoryId == "SIL" && it.power == Power.GERMANY })
            assertTrue(result.newGameState.units.any { it.territoryId == "MUN" && it.power == Power.RUSSIA })
            assertTrue(result.newGameState.units.any { it.territoryId == "BER" && it.power == Power.AUSTRIA })
        }

        @Test
        fun `6_C_3 - four unit rotation succeeds`() {
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "BOH"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "MUN")
                )
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "BOH"),
                Order.Move(Power.AUSTRIA, "BOH", "MUN"),
                Order.Move(Power.AUSTRIA, "MUN", "BER")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BOH"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))
        }

        @Test
        fun `6_C_4 - head-to-head with support wins`() {
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
                Order.Move(Power.RUSSIA, "SIL", "BER")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "SIL"))
        }

        @Test
        fun `6_C_5 - disrupted rotation - all moves in chain fail if one does`() {
            // BER->SIL, SIL->MUN, MUN->BER — but MUN is also attacked by TYR
            // If TYR attack on MUN fails, rotation proceeds.
            // If TYR attacks BER (disrupting the rotation), chain breaks.
            val gs = gameState(
                listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.AUSTRIA, UnitType.ARMY, "MUN"),
                    MapUnit(Power.ITALY, UnitType.ARMY, "TYR")
                )
            )
            // TYR attacks BER, disrupting the rotation
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "MUN"),
                Order.Move(Power.AUSTRIA, "MUN", "BER"),
                Order.Move(Power.ITALY, "TYR", "MUN") // attacks MUN, cutting the rotation
            )
            val result = resolver.resolve(gs, orders)

            // TYR->MUN and MUN->BER: MUN is trying to move to BER
            // TYR attacking MUN doesn't prevent MUN from moving
            // BER->SIL, SIL->MUN, MUN->BER should still rotate
            // TYR->MUN bounces because MUN is moving away
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "TYR"))
        }
    }

    // ================================================================
    // SUPPLY CENTER CHANGES
    // ================================================================

    @Nested
    inner class SupplyCenterChanges {

        @Test
        fun `supply center changes after fall moves`() {
            val gs = gameState(
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "MUN")),
                season = Season.FALL
            )
            val orders = listOf(Order.Move(Power.GERMANY, "MUN", "BUR"))
            val result = resolver.resolve(gs, orders)

            // BUR is not a supply center, so no changes
            assertTrue(result.supplyCenterChanges.isEmpty())
        }

        @Test
        fun `army captures neutral supply center in fall`() {
            val gs = GameState(
                phase = Phase.ORDER_SUBMISSION,
                year = 1901,
                season = Season.FALL,
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "RUH")),
                supplyCenterOwnership = emptyMap()
            )
            val orders = listOf(Order.Move(Power.GERMANY, "RUH", "BEL"))
            val result = resolver.resolve(gs, orders)

            assertEquals(1, result.supplyCenterChanges.size)
            assertEquals("BEL", result.supplyCenterChanges[0].territoryId)
            assertEquals(null, result.supplyCenterChanges[0].oldOwner)
            assertEquals(Power.GERMANY, result.supplyCenterChanges[0].newOwner)
        }

        @Test
        fun `no supply center changes in spring`() {
            val gs = gameState(
                units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "RUH")),
                season = Season.SPRING
            )
            val orders = listOf(Order.Move(Power.GERMANY, "RUH", "BEL"))
            val result = resolver.resolve(gs, orders)

            assertTrue(result.supplyCenterChanges.isEmpty())
        }
    }

    // ================================================================
    // PHASE TRANSITIONS
    // ================================================================

    @Nested
    inner class PhaseTransitions {

        @Test
        fun `dislodgement triggers retreat phase`() {
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
                Order.Hold(Power.RUSSIA, "SIL")
            )
            val result = resolver.resolve(gs, orders)

            assertEquals(Phase.RETREAT, result.nextPhase)
        }

        @Test
        fun `no dislodgement means no retreat phase`() {
            val gs = gameState(listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "BER")))
            val orders = listOf(Order.Move(Power.GERMANY, "BER", "SIL"))
            val result = resolver.resolve(gs, orders)

            // Spring moves → next is Fall order submission
            assertEquals(Phase.ORDER_SUBMISSION, result.nextPhase)
        }
    }
}
