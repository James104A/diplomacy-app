package com.diplomacy.adjudication

sealed class Order {
    abstract val power: Power
    abstract val unitTerritory: String

    data class Hold(
        override val power: Power,
        override val unitTerritory: String
    ) : Order()

    data class Move(
        override val power: Power,
        override val unitTerritory: String,
        val destination: String,
        val viaConvoy: Boolean = false
    ) : Order()

    data class Support(
        override val power: Power,
        override val unitTerritory: String,
        val supportedUnit: String,
        val supportedDestination: String? = null // null = support hold
    ) : Order()

    data class Convoy(
        override val power: Power,
        override val unitTerritory: String,
        val convoyedArmy: String,
        val destination: String
    ) : Order()

    data class Retreat(
        override val power: Power,
        override val unitTerritory: String,
        val destination: String
    ) : Order()

    data class Disband(
        override val power: Power,
        override val unitTerritory: String
    ) : Order()

    data class Build(
        override val power: Power,
        override val unitTerritory: String,
        val unitType: UnitType,
        val coast: String? = null
    ) : Order()

    data class Waive(
        override val power: Power,
        override val unitTerritory: String = ""
    ) : Order()
}
