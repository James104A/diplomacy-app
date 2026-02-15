package com.diplomacy.adjudication

data class AdjudicationResult(
    val resolvedOrders: List<ResolvedOrder>,
    val newGameState: GameState,
    val dislodgedUnits: List<DislodgedUnit>,
    val supplyCenterChanges: List<SupplyCenterChange>,
    val nextPhase: Phase
)

data class ResolvedOrder(
    val order: Order,
    val outcome: OrderOutcome,
    val reason: String? = null
)

enum class OrderOutcome {
    SUCCEEDED, FAILED, BOUNCED, DISLODGED, CUT, VOID, DISRUPTED
}

data class SupplyCenterChange(
    val territoryId: String,
    val oldOwner: Power?,
    val newOwner: Power
)
