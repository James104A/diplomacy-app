import SwiftUI

struct OrderPaletteView: View {
    let unit: UnitDto
    let availableOrders: [OrderType]
    let onSelect: (OrderType) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.xs) {
                // Header
                HStack {
                    let territory = TerritoryData.territory(for: unit.territoryId)
                    Image(systemName: unit.isArmy ? "shield.fill" : "sailboat.fill")
                        .foregroundColor(unit.powerEnum?.color() ?? .appSecondary)
                    Text(territory?.name ?? unit.territoryId)
                        .font(.appSecondaryBold)
                    Spacer()
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appSecondary)
                    }
                    .accessibilityLabel("Cancel order")
                }

                // Order type buttons
                HStack(spacing: Spacing.sm) {
                    ForEach(availableOrders, id: \.self) { orderType in
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            onSelect(orderType)
                        } label: {
                            VStack(spacing: Spacing.xxs) {
                                Image(systemName: orderType.icon)
                                    .font(.system(size: 20))
                                Text(orderType.displayName)
                                    .font(.appCaption)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: Spacing.xs)
                                    .fill(Color.appPrimary.opacity(0.1))
                            )
                        }
                        .foregroundColor(.appPrimary)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(orderType.displayName) order")
                        .accessibilityHint("Double tap to select \(orderType.displayName)")
                    }
                }
            }
            .padding(Spacing.md)
            .background(.ultraThinMaterial)
            .cornerRadius(Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
