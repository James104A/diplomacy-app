import SwiftUI

struct RulesReferenceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                rulesSection(
                    title: "Game Overview",
                    icon: "globe.europe.africa",
                    content: """
                    Diplomacy is a strategic board game set in pre-World War I Europe. \
                    Seven players each control one of the Great Powers: England, France, \
                    Germany, Italy, Austria-Hungary, Russia, and Turkey.

                    The goal is to control 18 of the 34 supply centers on the map. \
                    Players negotiate alliances, coordinate moves, and ultimately \
                    betray each other to achieve victory.
                    """
                )

                rulesSection(
                    title: "Phases",
                    icon: "arrow.triangle.2.circlepath",
                    content: """
                    Each game year has up to five phases:

                    Spring Diplomacy — Negotiate with other players.
                    Spring Orders — Submit movement orders for your units.
                    Fall Diplomacy — Negotiate again after spring results.
                    Fall Orders — Submit fall movement orders.
                    Winter Adjustments — Build or disband units based on supply center count.
                    """
                )

                rulesSection(
                    title: "Movement",
                    icon: "arrow.right",
                    content: """
                    Each unit (army or fleet) can hold, move to an adjacent territory, \
                    support another unit, or convoy.

                    Armies move between land territories. Fleets move between sea zones \
                    and coastal territories. A move succeeds if it has more support than \
                    any opposing move to the same territory.

                    If two units attempt to swap positions without a convoy, both moves fail.
                    """
                )

                rulesSection(
                    title: "Support",
                    icon: "person.2",
                    content: """
                    A unit can support another unit's hold or move into an adjacent \
                    territory. The supporting unit must be able to move to the target \
                    territory itself (even if it doesn't actually move).

                    Support is cut if the supporting unit is attacked from any territory \
                    other than the one it is supporting into. A unit that is dislodged \
                    cannot give support.
                    """
                )

                rulesSection(
                    title: "Convoy",
                    icon: "water.waves",
                    content: """
                    Fleets in sea zones can convoy armies across water. The army orders \
                    a move via convoy, and each fleet in the chain orders a convoy.

                    If any fleet in the convoy chain is dislodged, the entire convoy \
                    fails and the army remains in place. Multiple fleets can form a \
                    chain to convoy across several sea zones.
                    """
                )

                rulesSection(
                    title: "Retreats",
                    icon: "arrow.uturn.backward",
                    content: """
                    When a unit is dislodged (forced out of its territory by a stronger \
                    move), it must retreat to an adjacent empty territory or be disbanded.

                    A unit cannot retreat to the territory from which the attacker came, \
                    or to any territory that was contested (where a standoff occurred) \
                    during the same turn.
                    """
                )

                rulesSection(
                    title: "Builds & Disbands",
                    icon: "plus.circle",
                    content: """
                    After fall moves resolve, players count supply centers. If you \
                    control more supply centers than you have units, you may build \
                    new units in your unoccupied home supply centers.

                    If you have more units than supply centers, you must disband \
                    the excess. You choose which units to remove.
                    """
                )

                rulesSection(
                    title: "Victory",
                    icon: "trophy",
                    content: """
                    A player wins by controlling 18 supply centers after a fall \
                    adjudication. If no player reaches 18, the game can be drawn \
                    by agreement among the surviving players.

                    A draw requires all surviving players to agree. Eliminated \
                    players do not vote on draws.
                    """
                )
            }
            .padding(Spacing.md)
        }
        .background(Color.appBackground)
        .navigationTitle("Rules Reference")
        .navigationBarTitleDisplayMode(.large)
    }

    private func rulesSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(.appPrimary)
                    .frame(width: 24)
                Text(title)
                    .font(.appSectionHeader)
            }

            Text(content)
                .font(.appSecondary)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
}
