package com.diplomacy.adjudication

import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlin.test.assertFalse

class OrderValidatorTest {

    private val map = ClassicMap.definition

    private fun standardGameState(
        phase: Phase = Phase.ORDER_SUBMISSION,
        units: List<MapUnit> = defaultUnits(),
        dislodgedUnits: List<DislodgedUnit> = emptyList(),
        standoffTerritories: Set<String> = emptySet(),
        supplyCenterOwnership: Map<String, Power> = defaultOwnership()
    ) = GameState(
        phase = phase,
        year = 1901,
        season = Season.SPRING,
        units = units,
        supplyCenterOwnership = supplyCenterOwnership,
        dislodgedUnits = dislodgedUnits,
        standoffTerritories = standoffTerritories
    )

    private fun defaultUnits() = listOf(
        // Standard 1901 starting positions
        MapUnit(Power.AUSTRIA, UnitType.ARMY, "VIE"),
        MapUnit(Power.AUSTRIA, UnitType.ARMY, "BUD"),
        MapUnit(Power.AUSTRIA, UnitType.FLEET, "TRI"),
        MapUnit(Power.ENGLAND, UnitType.FLEET, "LON"),
        MapUnit(Power.ENGLAND, UnitType.FLEET, "EDI"),
        MapUnit(Power.ENGLAND, UnitType.ARMY, "LVP"),
        MapUnit(Power.FRANCE, UnitType.ARMY, "PAR"),
        MapUnit(Power.FRANCE, UnitType.ARMY, "MAR"),
        MapUnit(Power.FRANCE, UnitType.FLEET, "BRE"),
        MapUnit(Power.GERMANY, UnitType.ARMY, "BER"),
        MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
        MapUnit(Power.GERMANY, UnitType.FLEET, "KIE"),
        MapUnit(Power.ITALY, UnitType.ARMY, "ROM"),
        MapUnit(Power.ITALY, UnitType.ARMY, "VEN"),
        MapUnit(Power.ITALY, UnitType.FLEET, "NAP"),
        MapUnit(Power.RUSSIA, UnitType.ARMY, "MOS"),
        MapUnit(Power.RUSSIA, UnitType.ARMY, "WAR"),
        MapUnit(Power.RUSSIA, UnitType.FLEET, "SEV"),
        MapUnit(Power.RUSSIA, UnitType.FLEET, "STP_SC"),
        MapUnit(Power.TURKEY, UnitType.ARMY, "CON"),
        MapUnit(Power.TURKEY, UnitType.ARMY, "SMY"),
        MapUnit(Power.TURKEY, UnitType.FLEET, "ANK")
    )

    private fun defaultOwnership(): Map<String, Power> {
        val ownership = mutableMapOf<String, Power>()
        for ((id, terr) in map.territories) {
            if (terr.homeCenter != null) {
                ownership[id] = terr.homeCenter
            }
        }
        return ownership
    }

    // ================================================================
    // PHASE VALIDATION
    // ================================================================

    @Nested
    inner class PhaseValidation {

        @Test
        fun `hold is valid in order submission phase`() {
            val result = OrderValidator.validate(
                Order.Hold(Power.GERMANY, "BER"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `move is valid in order submission phase`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `retreat is invalid in order submission phase`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid order type for phase", result.errorCode)
        }

        @Test
        fun `build is invalid in order submission phase`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid order type for phase", result.errorCode)
        }

        @Test
        fun `hold is invalid in retreat phase`() {
            val gs = standardGameState(phase = Phase.RETREAT)
            val result = OrderValidator.validate(
                Order.Hold(Power.GERMANY, "BER"),
                gs,
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid order type for phase", result.errorCode)
        }

        @Test
        fun `retreat is valid in retreat phase`() {
            val gs = standardGameState(
                phase = Phase.RETREAT,
                units = defaultUnits().filter { it.territoryId != "BER" },
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                )
            )
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                gs,
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `build is valid in build phase`() {
            val gs = standardGameState(
                phase = Phase.BUILD,
                units = defaultUnits().filter { it.territoryId != "BER" }
            )
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                gs,
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `waive is valid in build phase`() {
            val gs = standardGameState(phase = Phase.BUILD)
            val result = OrderValidator.validate(
                Order.Waive(Power.GERMANY),
                gs,
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `move is invalid in build phase`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                standardGameState(phase = Phase.BUILD),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid order type for phase", result.errorCode)
        }
    }

    // ================================================================
    // SYNTACTIC VALIDATION
    // ================================================================

    @Nested
    inner class SyntacticValidation {

        @Test
        fun `unit not found is rejected`() {
            val result = OrderValidator.validate(
                Order.Hold(Power.GERMANY, "PAR"), // Germany has no unit in PAR
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Unit not found", result.errorCode)
        }

        @Test
        fun `wrong power is rejected`() {
            val result = OrderValidator.validate(
                Order.Move(Power.FRANCE, "BER", "SIL"), // BER belongs to Germany
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            // Should fail because France has no unit in BER
            assertEquals("VOID: Unit not found", result.errorCode)
        }

        @Test
        fun `move to unknown territory is rejected`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "XXX"),
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Unknown territory", result.errorCode)
        }

        @Test
        fun `support target that does not exist is rejected`() {
            val result = OrderValidator.validate(
                Order.Support(Power.GERMANY, "MUN", "TYR"), // No unit in TYR
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Support target not found", result.errorCode)
        }

        @Test
        fun `convoy by non-sea fleet is rejected`() {
            // Move fleet to a coastal territory first
            val units = listOf(
                MapUnit(Power.ENGLAND, UnitType.FLEET, "LON"),
                MapUnit(Power.FRANCE, UnitType.ARMY, "BRE")
            )
            val result = OrderValidator.validate(
                Order.Convoy(Power.ENGLAND, "LON", "BRE", "PIC"), // LON is coastal, not sea
                standardGameState(units = units),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid convoy configuration", result.errorCode)
        }

        @Test
        fun `convoy of a fleet is rejected`() {
            val units = listOf(
                MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH"),
                MapUnit(Power.FRANCE, UnitType.FLEET, "BEL") // fleet, not army
            )
            val result = OrderValidator.validate(
                Order.Convoy(Power.ENGLAND, "NTH", "BEL", "LON"),
                standardGameState(units = units),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Invalid convoy configuration", result.errorCode)
        }
    }

    // ================================================================
    // SEMANTIC VALIDATION — MOVE
    // ================================================================

    @Nested
    inner class MoveValidation {

        @Test
        fun `army move to adjacent territory succeeds`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "SIL"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `army move to non-adjacent territory is rejected with hold fallback`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "GAL"), // BER not adjacent to GAL
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Unreachable destination", result.errorCode)
            assertNotNull(result.fallbackOrder)
            assertTrue(result.fallbackOrder is Order.Hold)
        }

        @Test
        fun `army cannot move to sea zone`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "BER", "BAL"),
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Army cannot enter sea zone", result.errorCode)
            assertNotNull(result.fallbackOrder)
            assertTrue(result.fallbackOrder is Order.Hold)
        }

        @Test
        fun `fleet cannot move to inland territory`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "KIE", "MUN"), // MUN is inland
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Fleet cannot enter inland", result.errorCode)
        }

        @Test
        fun `fleet move to adjacent sea succeeds`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "KIE", "HEL"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `fleet move to adjacent coast succeeds`() {
            val result = OrderValidator.validate(
                Order.Move(Power.GERMANY, "KIE", "HOL"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `move via convoy skips adjacency check`() {
            val units = listOf(
                MapUnit(Power.ENGLAND, UnitType.ARMY, "LON"),
                MapUnit(Power.ENGLAND, UnitType.FLEET, "NTH")
            )
            val result = OrderValidator.validate(
                Order.Move(Power.ENGLAND, "LON", "NWY", viaConvoy = true),
                standardGameState(units = units),
                map
            )
            assertTrue(result.valid)
        }
    }

    // ================================================================
    // SEMANTIC VALIDATION — SUPPORT
    // ================================================================

    @Nested
    inner class SupportValidation {

        @Test
        fun `support hold for adjacent unit succeeds`() {
            val result = OrderValidator.validate(
                Order.Support(Power.AUSTRIA, "VIE", "BUD"),
                standardGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `support hold for non-adjacent unit is rejected`() {
            val result = OrderValidator.validate(
                Order.Support(Power.GERMANY, "BER", "MOS"), // BER not adjacent to MOS
                standardGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot support unreachable territory", result.errorCode)
            assertNotNull(result.fallbackOrder)
            assertTrue(result.fallbackOrder is Order.Hold)
        }

        @Test
        fun `support move to adjacent territory succeeds`() {
            val units = listOf(
                MapUnit(Power.GERMANY, UnitType.ARMY, "MUN"),
                MapUnit(Power.GERMANY, UnitType.ARMY, "BER")
            )
            val result = OrderValidator.validate(
                Order.Support(Power.GERMANY, "MUN", "BER", "SIL"),
                standardGameState(units = units),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `fleet cannot support into inland territory`() {
            val units = listOf(
                MapUnit(Power.GERMANY, UnitType.FLEET, "KIE"),
                MapUnit(Power.GERMANY, UnitType.ARMY, "BER")
            )
            val result = OrderValidator.validate(
                Order.Support(Power.GERMANY, "KIE", "BER", "MUN"), // fleet can't reach MUN (inland)
                standardGameState(units = units),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot support unreachable territory", result.errorCode)
        }
    }

    // ================================================================
    // SEMANTIC VALIDATION — RETREAT
    // ================================================================

    @Nested
    inner class RetreatValidation {

        private fun retreatGameState(
            occupiedTerritories: List<String> = emptyList(),
            standoffTerritories: Set<String> = emptySet()
        ): GameState {
            val units = occupiedTerritories.map {
                MapUnit(Power.FRANCE, UnitType.ARMY, it)
            }
            return standardGameState(
                phase = Phase.RETREAT,
                units = units,
                dislodgedUnits = listOf(
                    DislodgedUnit(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"), "MUN")
                ),
                standoffTerritories = standoffTerritories
            )
        }

        @Test
        fun `retreat to valid adjacent territory succeeds`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                retreatGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `retreat to non-adjacent territory is rejected`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "GAL"),
                retreatGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: No valid retreat", result.errorCode)
            assertNotNull(result.fallbackOrder)
            assertTrue(result.fallbackOrder is Order.Disband)
        }

        @Test
        fun `retreat to attacker origin is rejected`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "MUN"), // attacked from MUN
                retreatGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: No valid retreat", result.errorCode)
        }

        @Test
        fun `retreat to occupied territory is rejected`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                retreatGameState(occupiedTerritories = listOf("SIL")),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: No valid retreat", result.errorCode)
        }

        @Test
        fun `retreat to standoff territory is rejected`() {
            val result = OrderValidator.validate(
                Order.Retreat(Power.GERMANY, "BER", "SIL"),
                retreatGameState(standoffTerritories = setOf("SIL")),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: No valid retreat", result.errorCode)
        }
    }

    // ================================================================
    // SEMANTIC VALIDATION — BUILD
    // ================================================================

    @Nested
    inner class BuildValidation {

        private fun buildGameState(
            units: List<MapUnit> = emptyList(),
            ownership: Map<String, Power> = defaultOwnership()
        ) = standardGameState(
            phase = Phase.BUILD,
            units = units,
            supplyCenterOwnership = ownership
        )

        @Test
        fun `build army on unoccupied owned home center succeeds`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                buildGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `build fleet on unoccupied owned coastal home center succeeds`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "KIE", UnitType.FLEET),
                buildGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `build on non-home center is rejected`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BEL", UnitType.ARMY), // BEL is neutral
                buildGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot build there", result.errorCode)
        }

        @Test
        fun `build on enemy home center is rejected`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "PAR", UnitType.ARMY), // PAR is French home
                buildGameState(),
                map
            )
            assertFalse(result.valid)
        }

        @Test
        fun `build on occupied home center is rejected`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                buildGameState(units = listOf(MapUnit(Power.GERMANY, UnitType.ARMY, "BER"))),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot build there", result.errorCode)
        }

        @Test
        fun `build fleet on inland home center is rejected`() {
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "MUN", UnitType.FLEET), // MUN is inland
                buildGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot build there", result.errorCode)
        }

        @Test
        fun `build on home center not owned by power is rejected`() {
            val ownership = defaultOwnership().toMutableMap()
            ownership["BER"] = Power.FRANCE // BER captured by France
            val result = OrderValidator.validate(
                Order.Build(Power.GERMANY, "BER", UnitType.ARMY),
                buildGameState(ownership = ownership),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Cannot build there", result.errorCode)
        }

        @Test
        fun `build fleet on multi-coast territory requires coast specification`() {
            val result = OrderValidator.validate(
                Order.Build(Power.RUSSIA, "STP", UnitType.FLEET), // must specify STP_NC or STP_SC
                buildGameState(),
                map
            )
            assertFalse(result.valid)
            assertEquals("VOID: Must specify coast", result.errorCode)
        }

        @Test
        fun `build fleet on STP_SC succeeds`() {
            val result = OrderValidator.validate(
                Order.Build(Power.RUSSIA, "STP_SC", UnitType.FLEET),
                buildGameState(),
                map
            )
            assertTrue(result.valid)
        }

        @Test
        fun `build army on multi-coast territory succeeds without coast`() {
            val result = OrderValidator.validate(
                Order.Build(Power.RUSSIA, "STP", UnitType.ARMY),
                buildGameState(),
                map
            )
            assertTrue(result.valid)
        }
    }
}
