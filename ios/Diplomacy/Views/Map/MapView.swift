import SwiftUI

struct MapView: View {
    @StateObject var viewModel: MapViewModel
    var debugMode: Bool = false
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureDrag: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let mapSize = geometry.size

            ZStack {
                // Map layers: base image + ownership overlay + interactive overlay
                mapLayers(mapSize: mapSize)
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

    // MARK: - Map Layers

    /// Aspect ratio derived from the actual DiplomacyMap image asset at runtime.
    /// Falls back to SVG viewBox dimensions (1835×1360) if the image can't be loaded.
    static let mapAspect: CGFloat = {
        if let uiImage = UIImage(named: "DiplomacyMap") {
            let aspect = uiImage.size.width / uiImage.size.height
            print("✅ DiplomacyMap actual size: \(uiImage.size), aspect: \(aspect)")
            return aspect
        }
        print("⚠️ DiplomacyMap image not found, falling back to hardcoded aspect ratio")
        return 1835.0 / 1360.0
    }()

    private func mapLayers(mapSize: CGSize) -> some View {
        // Size the map content to fill available width, preserving aspect ratio
        let w = mapSize.width
        let h = w / Self.mapAspect

        return ZStack(alignment: .topLeading) {
            // Layer 1: SVG base map image (coastlines, borders, terrain, labels)
            Image("DiplomacyMap")
                .resizable()
                .frame(width: w, height: h)

            // Layer 2: Ownership color overlays + selection highlights
            ownershipOverlay(width: w, height: h)

            // Layer 3: Interactive elements (supply centers, units)
            interactiveOverlay(width: w, height: h)

            // Layer 4: Debug overlay (polygon outlines + center dots)
            if debugMode {
                debugOverlay(width: w, height: h)
            }
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
    }

    /// Semi-transparent ownership fills and selection/adjacency strokes.
    private func ownershipOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            // Ownership fills — only territories with an owner
            for territory in renderables {
                let color = viewModel.territoryColor(for: territory)
                guard color != .clear else { continue }
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                let opacity: Double = territory.isSea ? 0.25 : 0.35
                context.fill(path, with: .color(color.opacity(opacity)))
            }

            // Selection / adjacency highlights
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
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    /// Supply center markers and unit circles drawn over the base map.
    private func interactiveOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            // Supply center markers
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

            // Units
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

                // White outline behind for contrast over the map image
                context.stroke(Path(ellipseIn: unitRect), with: .color(.black.opacity(0.3)), lineWidth: 3)
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
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    // MARK: - Debug Overlay

    /// Draws polygon outlines (red) and territory center dots (green) for alignment verification.
    private func debugOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            // Red polygon outlines
            for territory in renderables {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                context.stroke(path, with: .color(.red), lineWidth: 1)
            }

            // Green center dots
            for territory in renderables {
                let center = CGPoint(x: territory.center.x * w, y: territory.center.y * h)
                let dotSize: CGFloat = 5
                let dotRect = CGRect(
                    x: center.x - dotSize / 2,
                    y: center.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(ellipseIn: dotRect), with: .color(.green))
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
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
