import SwiftUI

struct MapView: View {
    @StateObject var viewModel: MapViewModel
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureDrag: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let mapSize = geometry.size

            ZStack {
                // Map canvas
                mapCanvas(mapSize: mapSize)
                    .scaleEffect(viewModel.scale * gestureScale)
                    .offset(
                        x: viewModel.offset.width + gestureDrag.width,
                        y: viewModel.offset.height + gestureDrag.height
                    )
                    .gesture(combinedGesture)

                // Territory info overlay
                if viewModel.showTerritoryInfo, let territory = viewModel.selectedTerritory {
                    VStack {
                        Spacer()
                        TerritoryInfoOverlay(
                            territory: territory,
                            unit: viewModel.unitOn(territory.id),
                            owner: viewModel.ownerPower(for: territory.id),
                            showAdjacencies: viewModel.showAdjacencies,
                            palette: viewModel.palette
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTerritory?.id)
                }
            }
        }
        .background(Color(hex: 0xB3D9FF))
        .clipped()
        .task {
            await viewModel.loadGameState()
            viewModel.subscribeToWebSocket()
        }
    }

    // MARK: - Map Canvas

    private func mapCanvas(mapSize: CGSize) -> some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            // Pass 1: Sea zone fills
            for territory in renderables where territory.isSea {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                let fillColor = viewModel.territoryColor(for: territory)
                context.fill(path, with: .color(fillColor.opacity(0.35)))
            }

            // Pass 2: Land fills
            for territory in renderables where territory.isLand {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                let fillColor = viewModel.territoryColor(for: territory)
                context.fill(path, with: .color(fillColor.opacity(0.8)))
            }

            // Pass 3: Borders
            for territory in renderables {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                if territory.isSea {
                    context.stroke(path, with: .color(Color(hex: 0x6699CC).opacity(0.4)), lineWidth: 0.5)
                } else {
                    context.stroke(path, with: .color(.black.opacity(0.3)), lineWidth: 1)
                }
            }

            // Pass 4: Selection / adjacency highlights
            for territory in renderables {
                guard let poly = territory.polygon else { continue }
                let isSelected = viewModel.selectedTerritory?.id == territory.id
                let isAdjacent = viewModel.showAdjacencies &&
                    viewModel.selectedTerritory.flatMap { TerritoryData.adjacencies[$0.id]?.contains(territory.id) } ?? false

                if isSelected {
                    let path = polygonPath(poly, width: w, height: h)
                    context.stroke(path, with: .color(.white), lineWidth: 3)
                    context.stroke(path, with: .color(.yellow), lineWidth: 2)
                } else if isAdjacent {
                    let path = polygonPath(poly, width: w, height: h)
                    context.stroke(path, with: .color(.appWarning), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                }
            }

            // Pass 5: Supply center markers
            for territory in renderables where territory.isSupplyCenter {
                let center = CGPoint(x: territory.center.x * w, y: territory.center.y * h)
                let scSize: CGFloat = 6
                let scRect = CGRect(
                    x: center.x - scSize / 2,
                    y: center.y + 12,
                    width: scSize,
                    height: scSize
                )
                context.fill(Path(ellipseIn: scRect), with: .color(.white))
                context.stroke(Path(ellipseIn: scRect), with: .color(.black.opacity(0.5)), lineWidth: 0.75)
            }

            // Pass 6: Territory labels
            for territory in renderables {
                let showLabel = viewModel.showDetailedLabels || !territory.isSea
                guard showLabel else { continue }
                let center = CGPoint(x: territory.center.x * w, y: territory.center.y * h)
                let hasUnit = viewModel.unitOn(territory.id) != nil
                let labelY = hasUnit ? center.y - 10 : center.y - 2
                let labelSize: CGFloat = hasUnit ? 7 : 8
                let text = Text(territory.abbreviation)
                    .font(.system(size: labelSize, weight: .semibold))
                    .foregroundColor(territory.isSea ? .blue.opacity(0.6) : .black.opacity(0.7))
                context.draw(
                    context.resolve(text),
                    at: CGPoint(x: center.x, y: labelY),
                    anchor: .center
                )
            }

            // Pass 7: Units
            for territory in renderables {
                guard let unit = viewModel.unitOn(territory.id) else { continue }
                let center = CGPoint(x: territory.center.x * w, y: territory.center.y * h)
                let powerColor = unit.powerEnum?.color(palette: viewModel.palette) ?? .gray
                let unitRadius: CGFloat = 11
                let unitCenter = CGPoint(x: center.x, y: center.y + 4)
                let unitRect = CGRect(
                    x: unitCenter.x - unitRadius,
                    y: unitCenter.y - unitRadius,
                    width: unitRadius * 2,
                    height: unitRadius * 2
                )
                context.fill(Path(ellipseIn: unitRect), with: .color(powerColor))
                context.stroke(Path(ellipseIn: unitRect), with: .color(.white), lineWidth: 1.5)

                let unitText = Text(unit.isArmy ? "A" : "F")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                context.draw(
                    context.resolve(unitText),
                    at: unitCenter,
                    anchor: .center
                )
            }
        }
        .contentShape(Rectangle())
    }

    // MARK: - Polygon Helpers

    /// Build a closed Path from normalized polygon vertices scaled to map dimensions.
    private func polygonPath(_ vertices: [CGPoint], width: CGFloat, height: CGFloat) -> Path {
        guard vertices.count >= 3 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: vertices[0].x * width, y: vertices[0].y * height))
        for i in 1..<vertices.count {
            path.addLine(to: CGPoint(x: vertices[i].x * width, y: vertices[i].y * height))
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Gestures

    private var combinedGesture: some Gesture {
        let pinch = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                viewModel.scale = min(max(viewModel.scale * value, 0.5), 4.0)
            }

        let drag = DragGesture()
            .updating($gestureDrag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                viewModel.offset.width += value.translation.width
                viewModel.offset.height += value.translation.height
            }

        return pinch.simultaneously(with: drag)
    }
}

// MARK: - Point-in-Polygon Hit Testing

/// Ray-casting algorithm: cast horizontal ray from point, count polygon edge crossings.
/// Odd crossings = inside. Works with normalized 0-1 coordinates.
func pointInPolygon(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
    let n = polygon.count
    guard n >= 3 else { return false }
    var inside = false
    var j = n - 1
    for i in 0..<n {
        let vi = polygon[i]
        let vj = polygon[j]
        if (vi.y > point.y) != (vj.y > point.y) {
            let intersectX = vj.x + (point.y - vj.y) / (vi.y - vj.y) * (vi.x - vj.x)
            if point.x < intersectX {
                inside.toggle()
            }
        }
        j = i
    }
    return inside
}

/// Find territory at a normalized 0-1 map point. Tests land before sea so coastlines resolve to land.
func territoryAtPoint(_ normalizedPoint: CGPoint) -> Territory? {
    let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

    // Test land territories first (land overlaps sea at coastlines)
    for territory in renderables where territory.isLand {
        if let poly = territory.polygon, pointInPolygon(normalizedPoint, polygon: poly) {
            return territory
        }
    }
    // Then sea zones
    for territory in renderables where territory.isSea {
        if let poly = territory.polygon, pointInPolygon(normalizedPoint, polygon: poly) {
            return territory
        }
    }
    return nil
}
