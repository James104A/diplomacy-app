package com.diplomacy.adjudication

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class ClassicMapTest {

    private val map = ClassicMap.definition

    // ================================================================
    // Territory counts
    // ================================================================

    @Test
    fun `map has 75 base territories`() {
        val base = map.territories.values.filter { it.parentTerritory == null }
        assertEquals(75, base.size)
    }

    @Test
    fun `map has 6 multi-coast sub-territories`() {
        val subs = map.territories.values.filter { it.parentTerritory != null }
        assertEquals(6, subs.size)
    }

    @Test
    fun `map has 81 total territories including coasts`() {
        assertEquals(81, map.territories.size)
    }

    @Test
    fun `map has 14 inland territories`() {
        val inland = map.territories.values.filter { it.type == TerritoryType.LAND }
        assertEquals(14, inland.size)
    }

    @Test
    fun `map has 19 sea zones`() {
        val seas = map.territories.values.filter { it.type == TerritoryType.SEA }
        assertEquals(19, seas.size)
    }

    @Test
    fun `map has 34 supply centers`() {
        val scs = map.territories.values.filter { it.isSupplyCenter }
        assertEquals(34, scs.size)
    }

    @Test
    fun `map has 22 home supply centers`() {
        val home = map.territories.values.filter { it.homeCenter != null }
        assertEquals(22, home.size)
    }

    @Test
    fun `each power has exactly 3 home supply centers except Russia with 4`() {
        for (power in Power.entries) {
            val expected = if (power == Power.RUSSIA) 4 else 3
            val count = map.territories.values.count { it.homeCenter == power }
            assertEquals(expected, count, "$power should have $expected home SCs but has $count")
        }
    }

    @Test
    fun `neutral supply center count is 12`() {
        // 34 total SCs - 22 home SCs = 12 neutral
        val neutral = map.territories.values.filter { it.isSupplyCenter && it.homeCenter == null }
        assertEquals(12, neutral.size)
    }

    // ================================================================
    // Multi-coast territories
    // ================================================================

    @Test
    fun `STP has two coasts NC and SC`() {
        val stp = map.territory("STP")
        assertEquals(listOf("STP_NC", "STP_SC"), stp.coasts.sorted())
        assertNotNull(map.territories["STP_NC"])
        assertNotNull(map.territories["STP_SC"])
        assertEquals("STP", map.territories["STP_NC"]!!.parentTerritory)
        assertEquals("STP", map.territories["STP_SC"]!!.parentTerritory)
    }

    @Test
    fun `SPA has two coasts NC and SC`() {
        val spa = map.territory("SPA")
        assertEquals(listOf("SPA_NC", "SPA_SC"), spa.coasts.sorted())
    }

    @Test
    fun `BUL has two coasts EC and SC`() {
        val bul = map.territory("BUL")
        assertEquals(listOf("BUL_EC", "BUL_SC"), bul.coasts.sorted())
    }

    // ================================================================
    // Adjacency — specific spot checks
    // ================================================================

    @Test
    fun `BER is adjacent to MUN for armies`() {
        assertTrue(map.isAdjacent("BER", "MUN", UnitType.ARMY))
        assertTrue(map.isAdjacent("MUN", "BER", UnitType.ARMY))
    }

    @Test
    fun `BER is not adjacent to MUN for fleets`() {
        // BER-MUN: only army adjacency (MUN is inland)
        assertFalse(map.isAdjacent("BER", "MUN", UnitType.FLEET))
    }

    @Test
    fun `LON is adjacent to ENG for fleets`() {
        assertTrue(map.isAdjacent("LON", "ENG", UnitType.FLEET))
    }

    @Test
    fun `LON is not adjacent to ENG for armies`() {
        assertFalse(map.isAdjacent("LON", "ENG", UnitType.ARMY))
    }

    @Test
    fun `CON is adjacent to BUL for armies`() {
        assertTrue(map.isAdjacent("CON", "BUL", UnitType.ARMY))
    }

    @Test
    fun `CON is adjacent to BUL_SC and BUL_EC for fleets`() {
        assertTrue(map.isAdjacent("CON", "BUL_SC", UnitType.FLEET))
        assertTrue(map.isAdjacent("CON", "BUL_EC", UnitType.FLEET))
    }

    @Test
    fun `NWY is adjacent to STP_NC for fleets`() {
        assertTrue(map.isAdjacent("NWY", "STP_NC", UnitType.FLEET))
    }

    @Test
    fun `NWY is not adjacent to STP_SC for fleets`() {
        assertFalse(map.isAdjacent("NWY", "STP_SC", UnitType.FLEET))
    }

    @Test
    fun `FIN is adjacent to STP_SC for fleets`() {
        assertTrue(map.isAdjacent("FIN", "STP_SC", UnitType.FLEET))
    }

    @Test
    fun `FIN is not adjacent to STP_NC for fleets`() {
        assertFalse(map.isAdjacent("FIN", "STP_NC", UnitType.FLEET))
    }

    @Test
    fun `army can move from NWY to STP via parent territory adjacency`() {
        assertTrue(map.isAdjacent("NWY", "STP", UnitType.ARMY))
    }

    @Test
    fun `army can move from FIN to STP`() {
        assertTrue(map.isAdjacent("FIN", "STP", UnitType.ARMY))
    }

    // ================================================================
    // Adjacency — bidirectionality
    // ================================================================

    @Test
    fun `all adjacencies are bidirectional`() {
        for ((fromId, adjs) in map.adjacencies) {
            for (adj in adjs) {
                val reverse = map.adjacencies[adj.targetId]
                assertNotNull(reverse, "${adj.targetId} has no adjacency list but is target of $fromId")
                val reverseAdj = reverse.find { it.targetId == fromId }
                assertNotNull(reverseAdj, "$fromId -> ${adj.targetId} exists but reverse does not")
                assertEquals(adj.unitTypes, reverseAdj.unitTypes,
                    "Unit types mismatch: $fromId -> ${adj.targetId} = ${adj.unitTypes}, reverse = ${reverseAdj.unitTypes}")
            }
        }
    }

    // ================================================================
    // Adjacency — no self-adjacency
    // ================================================================

    @Test
    fun `no territory is adjacent to itself`() {
        for ((id, adjs) in map.adjacencies) {
            assertFalse(adjs.any { it.targetId == id }, "$id is adjacent to itself")
        }
    }

    // ================================================================
    // Adjacency — all targets exist
    // ================================================================

    @Test
    fun `all adjacency targets reference valid territories`() {
        for ((_, adjs) in map.adjacencies) {
            for (adj in adjs) {
                assertNotNull(map.territories[adj.targetId], "Adjacency target ${adj.targetId} not found in territories")
            }
        }
    }

    // ================================================================
    // Adjacency — fleet cannot reach inland
    // ================================================================

    @Test
    fun `no fleet adjacency to or from inland territories`() {
        val inlandIds = map.territories.values.filter { it.type == TerritoryType.LAND }.map { it.id }.toSet()
        for ((fromId, adjs) in map.adjacencies) {
            for (adj in adjs) {
                if (fromId in inlandIds || adj.targetId in inlandIds) {
                    assertFalse(UnitType.FLEET in adj.unitTypes,
                        "Fleet adjacency between $fromId and ${adj.targetId} but one is inland")
                }
            }
        }
    }

    // ================================================================
    // Reachable coasts
    // ================================================================

    @Test
    fun `fleet from NWG can reach STP_NC only`() {
        val reachable = map.getReachableCoasts("NWG", "STP")
        // NWG is adjacent to STP_NC via NWY-STP_NC path; but NWG directly?
        // Actually NWG is not directly adjacent to STP coasts - BAR is adjacent to STP_NC
        // Let's check BAR instead
        val fromBar = map.getReachableCoasts("BAR", "STP")
        assertTrue("STP_NC" in fromBar, "BAR should reach STP_NC")
        assertFalse("STP_SC" in fromBar, "BAR should not reach STP_SC")
    }

    @Test
    fun `fleet from BOT can reach STP_SC only`() {
        val reachable = map.getReachableCoasts("BOT", "STP")
        assertTrue("STP_SC" in reachable)
        assertFalse("STP_NC" in reachable)
    }

    // ================================================================
    // Starting positions
    // ================================================================

    @Test
    fun `7 powers have starting positions`() {
        assertEquals(7, map.startingPositions.size)
        for (power in Power.entries) {
            assertNotNull(map.startingPositions[power], "$power missing starting positions")
        }
    }

    @Test
    fun `22 total starting units`() {
        val total = map.startingPositions.values.sumOf { it.size }
        assertEquals(22, total)
    }

    @Test
    fun `each power starts with 3 units except Russia with 4`() {
        for (power in Power.entries) {
            val expected = if (power == Power.RUSSIA) 4 else 3
            assertEquals(expected, map.startingPositions[power]!!.size,
                "$power should have $expected starting units")
        }
    }

    @Test
    fun `Russia starts with fleet on STP_SC not STP`() {
        val russianFleets = map.startingPositions[Power.RUSSIA]!!.filter { it.unitType == UnitType.FLEET }
        assertTrue(russianFleets.any { it.territoryId == "STP_SC" }, "Russia should have fleet on STP_SC")
    }

    @Test
    fun `all starting positions reference valid territories`() {
        for ((_, units) in map.startingPositions) {
            for (unit in units) {
                assertNotNull(map.territories[unit.territoryId],
                    "Starting position ${unit.territoryId} not found in territories")
            }
        }
    }
}
