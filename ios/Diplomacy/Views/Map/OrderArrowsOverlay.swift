import SwiftUI

struct OrderArrowsOverlay: View {
    let orders: [OrderDto]
    let activeOrder: OrderDto?
    let mapSize: CGSize
    let palette: PowerPalette

    var body: some View {
        Canvas { context, size in
            for order in orders {
                drawOrder(order, in: context, size: size, isActive: order == activeOrder)
            }
        }
        .frame(width: mapSize.width, height: mapSize.height)
    }

    private func drawOrder(_ order: OrderDto, in context: GraphicsContext, size: CGSize, isActive: Bool) {
        switch order.type {
        case "MOVE":
            guard let origin = order.origin, let dest = order.destination else { return }
            drawArrow(
                from: territoryCenter(origin, in: size),
                to: territoryCenter(dest, in: size),
                in: context,
                color: .appPrimary,
                isDashed: false,
                isActive: isActive
            )

        case "SUPPORT":
            guard let origin = order.origin, let target = order.supportTarget else { return }
            let from = territoryCenter(origin, in: size)
            let to = territoryCenter(target.origin, in: size)
            drawArrow(
                from: from,
                to: to,
                in: context,
                color: .appSuccess,
                isDashed: true,
                isActive: isActive
            )
            // If supporting a move, draw a faint continuation arrow
            if let dest = target.destination {
                let destPoint = territoryCenter(dest, in: size)
                drawArrow(
                    from: to,
                    to: destPoint,
                    in: context,
                    color: .appSuccess.opacity(0.4),
                    isDashed: true,
                    isActive: false
                )
            }

        case "CONVOY":
            guard let origin = order.origin, let target = order.convoyTarget else { return }
            let from = territoryCenter(origin, in: size)
            let convoyFrom = territoryCenter(target.origin, in: size)
            let convoyTo = territoryCenter(target.destination, in: size)
            // Draw line from fleet to convoy path
            drawArrow(
                from: convoyFrom,
                to: convoyTo,
                in: context,
                color: .appWarning,
                isDashed: true,
                isActive: isActive
            )
            // Indicate fleet involvement
            let midpoint = CGPoint(
                x: (convoyFrom.x + convoyTo.x) / 2,
                y: (convoyFrom.y + convoyTo.y) / 2
            )
            drawArrow(
                from: from,
                to: midpoint,
                in: context,
                color: .appWarning.opacity(0.5),
                isDashed: true,
                isActive: false
            )

        case "HOLD":
            guard let origin = order.origin else { return }
            let center = territoryCenter(origin, in: size)
            let holdSize: CGFloat = 16
            let rect = CGRect(x: center.x - holdSize / 2, y: center.y - holdSize / 2, width: holdSize, height: holdSize)
            context.stroke(Path(ellipseIn: rect), with: .color(.appSecondary), lineWidth: 2)

        default:
            break
        }
    }

    private func drawArrow(
        from: CGPoint,
        to: CGPoint,
        in context: GraphicsContext,
        color: Color,
        isDashed: Bool,
        isActive: Bool
    ) {
        // Main line
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)

        let lineWidth: CGFloat = isActive ? 3 : 2
        let style = isDashed ?
            StrokeStyle(lineWidth: lineWidth, dash: [6, 4]) :
            StrokeStyle(lineWidth: lineWidth)

        context.stroke(path, with: .color(color), style: style)

        // Arrowhead
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6

        var arrowPath = Path()
        arrowPath.move(to: to)
        arrowPath.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        ))
        arrowPath.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        ))
        arrowPath.closeSubpath()
        context.fill(arrowPath, with: .color(color))
    }

    private func territoryCenter(_ id: String, in size: CGSize) -> CGPoint {
        guard let territory = TerritoryData.territory(for: id) else {
            return CGPoint(x: size.width / 2, y: size.height / 2)
        }
        return CGPoint(
            x: territory.unitAnchor.x * size.width,
            y: territory.unitAnchor.y * size.height
        )
    }
}
