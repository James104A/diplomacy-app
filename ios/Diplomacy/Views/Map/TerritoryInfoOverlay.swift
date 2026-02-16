import SwiftUI

struct TerritoryInfoOverlay: View {
    let territory: Territory
    let unit: UnitDto?
    let owner: Power?
    let showAdjacencies: Bool
    let palette: PowerPalette

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Territory name + type
            HStack {
                if territory.isSupplyCenter {
                    Image(systemName: "star.fill")
                        .font(.appCaption)
                        .foregroundColor(.appWarning)
                }

                Text(territory.name)
                    .font(.appTitle)

                Text("(\(territory.abbreviation))")
                    .font(.appCaption)
                    .foregroundColor(.appSecondary)

                Spacer()

                Text(territory.type.rawValue.uppercased())
                    .font(.appBadge)
                    .foregroundColor(.appSecondary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appSecondary.opacity(0.1))
                    )
            }

            // Owner
            if let owner {
                HStack(spacing: Spacing.xxs) {
                    Circle()
                        .fill(owner.color(palette: palette))
                        .frame(width: 12, height: 12)
                    Text("Controlled by \(owner.displayName)")
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                    Spacer()
                }
            }

            // Unit present
            if let unit {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: unit.isArmy ? "shield.fill" : "sailboat.fill")
                        .foregroundColor(unit.powerEnum?.color(palette: palette) ?? .appSecondary)
                    Text("\(unit.powerEnum?.displayName ?? unit.power) \(unit.isArmy ? "Army" : "Fleet")")
                        .font(.appSecondaryBold)
                    Spacer()
                }
            }

            // Adjacencies
            if showAdjacencies {
                let adjacent = TerritoryData.adjacentTerritories(for: territory.id)
                    .filter { $0.parentTerritory == nil }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Adjacent Territories")
                        .font(.appSecondaryBold)

                    FlowLayout(spacing: Spacing.xxs) {
                        ForEach(adjacent) { adj in
                            Text(adj.abbreviation)
                                .font(.appCaption)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(adj.isSea ? Color(hex: 0xB3D9FF).opacity(0.5) : Color.appSecondary.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial)
        .cornerRadius(Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
