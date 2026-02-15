package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Integration tests for the Adjudicator facade.
 * Covers DATC 6.H edge cases and end-to-end scenarios.
 */
class AdjudicatorTest {

    private val adjudicator = Adjudicator()

    private fun outcome(result: AdjudicationResult, territory: String): OrderOutcome =
        result.resolvedOrders.first { it.order.unitTerritory == territory }.outcome

    @Nested
    inner class InitialState {

        @Test
        fun `creates initial game state with 22 units`() {
            val gs = adjudicator.createInitialGameState()
            assertEquals(22, gs.units.size)
            assertEquals(Phase.ORDER_SUBMISSION, gs.phase)
            assertEquals(1901, gs.year)
            assertEquals(Season.SPRING, gs.season)
        }

        @Test
        fun `initial state has 22 owned supply centers`() {
            val gs = adjudicator.createInitialGameState()
            assertEquals(22, gs.supplyCenterOwnership.size)
        }

        @Test
        fun `Russia starts with 4 units`() {
            val gs = adjudicator.createInitialGameState()
            assertEquals(4, gs.units.count { it.power == Power.RUSSIA })
        }

        @Test
        fun `Russia fleet starts on STP_SC`() {
            val gs = adjudicator.createInitialGameState()
            assertTrue(gs.units.any { it.power == Power.RUSSIA && it.territoryId == "STP_SC" && it.type == UnitType.FLEET })
        }
    }

    @Nested
    inner class EndToEndScenarios {

        @Test
        fun `simple spring move from initial position`() {
            val gs = adjudicator.createInitialGameState()
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.GERMANY, "MUN", "RUH"),
                Order.Move(Power.GERMANY, "KIE", "HOL")
            )
            val result = adjudicator.adjudicate(gs, orders)

            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MUN"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "KIE"))

            assertTrue(result.newGameState.units.any { it.territoryId == "SIL" && it.power == Power.GERMANY })
            assertTrue(result.newGameState.units.any { it.territoryId == "RUH" && it.power == Power.GERMANY })
            assertTrue(result.newGameState.units.any { it.territoryId == "HOL" && it.power == Power.GERMANY })
        }

        @Test
        fun `invalid orders are converted to holds`() {
            val gs = adjudicator.createInitialGameState()
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "GAL") // not adjacent
            )
            val result = adjudicator.adjudicate(gs, orders)

            // BER should still be in place (invalid move → hold)
            assertTrue(result.newGameState.units.any { it.territoryId == "BER" && it.power == Power.GERMANY })
        }
    }

    // ================================================================
    // DATC 6.H — EDGE CASES
    // ================================================================

    @Nested
    inner class EdgeCases {

        @Test
        fun `6_H_1 - no orders submitted - all units hold`() {
            val gs = adjudicator.createInitialGameState()
            val result = adjudicator.adjudicate(gs, emptyList())

            // All 22 units should remain in their starting positions
            assertEquals(22, result.newGameState.units.size)
            for (unit in gs.units) {
                assertTrue(result.newGameState.units.any {
                    it.territoryId == unit.territoryId && it.power == unit.power
                }, "Unit at ${unit.territoryId} should still be there")
            }
        }

        @Test
        fun `6_H_2 - all seven powers submit moves simultaneously`() {
            val gs = adjudicator.createInitialGameState()
            val orders = listOf(
                // Austria
                Order.Move(Power.AUSTRIA, "VIE", "GAL"),
                Order.Move(Power.AUSTRIA, "BUD", "SER"),
                Order.Move(Power.AUSTRIA, "TRI", "ADR"),
                // England
                Order.Move(Power.ENGLAND, "LON", "NTH"),
                Order.Move(Power.ENGLAND, "EDI", "NWG"),
                Order.Move(Power.ENGLAND, "LVP", "YOR"),
                // France
                Order.Move(Power.FRANCE, "PAR", "BUR"),
                Order.Move(Power.FRANCE, "MAR", "SPA"),
                Order.Move(Power.FRANCE, "BRE", "MAO"),
                // Germany
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.GERMANY, "MUN", "RUH"),
                Order.Move(Power.GERMANY, "KIE", "HOL"),
                // Italy
                Order.Move(Power.ITALY, "ROM", "APU"),
                Order.Move(Power.ITALY, "VEN", "TYR"),
                Order.Move(Power.ITALY, "NAP", "ION"),
                // Russia
                Order.Move(Power.RUSSIA, "MOS", "UKR"),
                Order.Move(Power.RUSSIA, "WAR", "LVN"),
                Order.Move(Power.RUSSIA, "SEV", "BLA"),
                Order.Move(Power.RUSSIA, "STP_SC", "BOT"),
                // Turkey
                Order.Move(Power.TURKEY, "CON", "BUL"),
                Order.Move(Power.TURKEY, "SMY", "ARM"),
                Order.Move(Power.TURKEY, "ANK", "BLA") // conflicts with Russia SEV->BLA
            )
            val result = adjudicator.adjudicate(gs, orders)

            // Most moves succeed except BLA conflict
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "VIE"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "LON"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "PAR"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "ROM"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "MOS"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "CON"))

            // SEV and ANK both try to go to BLA — bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "SEV"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "ANK"))

            assertEquals(22, result.newGameState.units.size)
        }

        @Test
        fun `6_H_3 - support cutting does not prevent the move it supports`() {
            // A cuts B's support for C, but C still has enough strength to succeed
            val gs = GameState(
                phase = Phase.ORDER_SUBMISSION,
                year = 1901,
                season = Season.SPRING,
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "PRU"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "BOH")
                ),
                supplyCenterOwnership = emptyMap()
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Support(Power.GERMANY, "PRU", "BER", "SIL"),
                Order.Hold(Power.RUSSIA, "SIL"),
                Order.Move(Power.RUSSIA, "BOH", "MUN") // cuts one support
            )
            val result = adjudicator.adjudicate(gs, orders)

            // MUN support is cut, but PRU support still counts
            // Germany attack: 1 + 1 = 2 (one support cut), Russia defense: 1
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.DISLODGED, outcome(result, "SIL"))
        }

        @Test
        fun `6_H_4 - convoyed army can cut support`() {
            val gs = GameState(
                phase = Phase.ORDER_SUBMISSION,
                year = 1901,
                season = Season.SPRING,
                units = listOf(
                    MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                    MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                    MapUnit(Power.FRANCE, UnitType.ARMY, "BEL"),
                    MapUnit(Power.FRANCE, UnitType.ARMY, "BUR")
                ),
                supplyCenterOwnership = emptyMap()
            )
            val orders = listOf(
                Order.Move(Power.ENGLAND, "LON", "BEL", viaConvoy = true),
                Order.Convoy(Power.ENGLAND, "NTH", "LON", "BEL"),
                Order.Support(Power.FRANCE, "BEL", "BUR", "RUH"), // BEL supports BUR->RUH
                Order.Move(Power.FRANCE, "BUR", "RUH")
            )
            val result = adjudicator.adjudicate(gs, orders)

            // Convoyed army from LON attacks BEL, cutting BEL's support
            assertEquals(OrderOutcome.CUT, outcome(result, "BEL"))
        }

        @Test
        fun `6_H_5 - bounced unit still has defense strength`() {
            val gs = GameState(
                phase = Phase.ORDER_SUBMISSION,
                year = 1901,
                season = Season.SPRING,
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "SIL"),
                    MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR")
                ),
                supplyCenterOwnership = emptyMap()
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Move(Power.RUSSIA, "SIL", "MUN"), // bounces (MUN occupied? No, empty — succeeds)
                Order.Hold(Power.RUSSIA, "WAR")
            )
            val result = adjudicator.adjudicate(gs, orders)

            // SIL moves to MUN (empty), so BER can move to SIL
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
        }

        @Test
        fun `6_H_6 - unit cannot dislodge itself through support`() {
            val gs = GameState(
                phase = Phase.ORDER_SUBMISSION,
                year = 1901,
                season = Season.SPRING,
                units = listOf(
                    MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                    MapUnit(Power.GERMANY, UnitType.ARMY, "SIL")
                ),
                supplyCenterOwnership = emptyMap()
            )
            val orders = listOf(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                Order.Hold(Power.GERMANY, "SIL")
            )
            val result = adjudicator.adjudicate(gs, orders)

            // Cannot dislodge own unit
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SIL"))
        }
    }

    @Nested
    inner class FullTurnCycle {

        @Test
        fun `complete spring 1901 turn with all powers`() {
            val gs = adjudicator.createInitialGameState()

            // Standard opening moves
            val orders = listOf(
                Order.Move(Power.AUSTRIA, "VIE", "BUD"),
                Order.Move(Power.AUSTRIA, "BUD", "SER"),
                Order.Move(Power.AUSTRIA, "TRI", "ALB"),
                Order.Move(Power.ENGLAND, "LON", "NTH"),
                Order.Move(Power.ENGLAND, "EDI", "NWG"),
                Order.Move(Power.ENGLAND, "LVP", "YOR"),
                Order.Move(Power.FRANCE, "PAR", "BUR"),
                Order.Move(Power.FRANCE, "MAR", "SPA"),
                Order.Move(Power.FRANCE, "BRE", "MAO"),
                Order.Move(Power.GERMANY, "BER", "KIE"),
                Order.Move(Power.GERMANY, "MUN", "RUH"),
                Order.Move(Power.GERMANY, "KIE", "DEN"),
                Order.Move(Power.ITALY, "ROM", "APU"),
                Order.Move(Power.ITALY, "VEN", "PIE"),
                Order.Move(Power.ITALY, "NAP", "ION"),
                Order.Move(Power.RUSSIA, "MOS", "UKR"),
                Order.Move(Power.RUSSIA, "WAR", "GAL"),
                Order.Move(Power.RUSSIA, "SEV", "BLA"),
                Order.Move(Power.RUSSIA, "STP_SC", "BOT"),
                Order.Move(Power.TURKEY, "CON", "BUL"),
                Order.Move(Power.TURKEY, "SMY", "CON"),
                Order.Move(Power.TURKEY, "ANK", "BLA") // BLA conflict with Russia
            )

            val result = adjudicator.adjudicate(gs, orders)

            // BER->KIE and KIE->DEN form a rotation, should succeed
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BER"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "KIE"))

            // SEV->BLA and ANK->BLA should bounce
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "SEV"))
            assertEquals(OrderOutcome.BOUNCED, outcome(result, "ANK"))

            // VIE->BUD and BUD->SER is a chain, should work
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "VIE"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "BUD"))

            // CON->BUL and SMY->CON is a chain
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "CON"))
            assertEquals(OrderOutcome.SUCCEEDED, outcome(result, "SMY"))

            assertEquals(22, result.newGameState.units.size)
        }
    }
}
