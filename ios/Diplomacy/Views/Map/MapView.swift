import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    var debugMode: Bool = false

    // Callbacks for tap events — GameView handles game logic
    var onTap: ((CGPoint) -> Void)?       // normalized 0-1 map coords
    var onDoubleTap: (() -> Void)?
    var onLongPress: ((CGPoint) -> Void)?  // normalized 0-1 map coords

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureDrag: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let mapSize = geometry.size

            ZStack {
                mapLayers(mapSize: mapSize)
                    .scaleEffect(viewModel.scale * gestureScale)
                    .offset(
                        x: viewModel.offset.width + gestureDrag.width,
                        y: viewModel.offset.height + gestureDrag.height
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                onDoubleTap?()
            }
            .onTapGesture(count: 1) { location in
                let normalized = screenToMap(location, in: mapSize)
                onTap?(normalized)
            }
            .gesture(longPressGesture(in: mapSize))
            .simultaneousGesture(pinchAndDragGesture)
            .onAppear {
                viewModel.screenSize = geometry.size
                viewModel.trySetInitialPosition()
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.screenSize = newSize
            }
        }
        .background(Color(hex: 0xB3D9FF))
        .clipped()
    }

    // MARK: - Map Layers

    /// Aspect ratio derived from the actual DiplomacyMap image asset at runtime.
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
        let w = mapSize.width
        let h = w / Self.mapAspect

        return ZStack(alignment: .topLeading) {
            Image("DiplomacyMap")
                .resizable()
                .frame(width: w, height: h)

            ownershipOverlay(width: w, height: h)
            interactiveOverlay(width: w, height: h)

            if viewModel.showDetailedLabels {
                labelOverlay(width: w, height: h)
            }

            if debugMode {
                debugOverlay(width: w, height: h)
            }
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
    }

    // MARK: - Coordinate Conversion

    /// Convert a screen tap to normalized 0-1 map coordinates.
    /// Uses the SAME GeometryReader size as the rendering, so coordinates always match.
    private func screenToMap(_ screenPoint: CGPoint, in viewSize: CGSize) -> CGPoint {
        guard viewSize.width > 0, viewSize.height > 0 else { return .zero }
        let mapHeight = viewSize.width / Self.mapAspect
        let x = (screenPoint.x - viewSize.width / 2 - viewModel.offset.width) / viewModel.scale + viewSize.width / 2
        let y = (screenPoint.y - viewSize.height / 2 - viewModel.offset.height) / viewModel.scale + mapHeight / 2
        return CGPoint(x: x / viewSize.width, y: y / mapHeight)
    }

    // MARK: - Gestures

    /// Combined pinch + drag gesture for zoom and pan.
    private var pinchAndDragGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                let newScale = (viewModel.scale * value).clamped(to: 1.0...5.0)
                withAnimation(.easeOut(duration: 0.15)) {
                    viewModel.scale = newScale
                    viewModel.offset = viewModel.clampOffset(
                        viewModel.offset, scale: newScale, screenSize: viewModel.screenSize
                    )
                }
            }
            .simultaneously(with:
                DragGesture()
                    .updating($gestureDrag) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        let proposed = CGSize(
                            width: viewModel.offset.width + value.translation.width,
                            height: viewModel.offset.height + value.translation.height
                        )
                        viewModel.offset = viewModel.clampOffset(
                            proposed, scale: viewModel.scale, screenSize: viewModel.screenSize
                        )
                    }
            )
    }

    /// Long-press gesture to show adjacencies.
    private func longPressGesture(in viewSize: CGSize) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onEnded { value in
                switch value {
                case .second(true, let drag):
                    if let location = drag?.location {
                        let normalized = screenToMap(location, in: viewSize)
                        onLongPress?(normalized)
                    }
                default:
                    break
                }
            }
    }

    // MARK: - Overlays

    private func ownershipOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables {
                let color = viewModel.territoryColor(for: territory)
                guard color != .clear else { continue }
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                let opacity: Double = territory.isSea ? 0.25 : 0.35
                context.fill(path, with: .color(color.opacity(opacity)))
            }

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

    private func interactiveOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        let currentScale = viewModel.scale
        let unitRadius = (11.0 / currentScale).clamped(to: 6...18)
        let fontSize = (12.0 / currentScale).clamped(to: 7...16)
        let strokeWidth = (1.5 / currentScale).clamped(to: 0.5...2.5)
        let bgStrokeWidth = (3.0 / currentScale).clamped(to: 1.0...4.0)
        let scSize = (6.0 / currentScale).clamped(to: 3...10)
        let scOffset = (12.0 / currentScale).clamped(to: 6...18)

        return Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables where territory.isSupplyCenter {
                let center = CGPoint(x: territory.unitAnchor.x * w, y: territory.unitAnchor.y * h)
                let scRect = CGRect(
                    x: center.x - scSize / 2,
                    y: center.y + scOffset,
                    width: scSize,
                    height: scSize
                )
                context.fill(Path(ellipseIn: scRect), with: .color(.white))
                context.stroke(Path(ellipseIn: scRect), with: .color(.black.opacity(0.5)), lineWidth: 0.75)
            }

            for territory in renderables {
                guard let unit = viewModel.unitOn(territory.id) else { continue }
                let center = CGPoint(x: territory.unitAnchor.x * w, y: territory.unitAnchor.y * h)
                let powerColor = unit.powerEnum?.color(palette: viewModel.palette) ?? .gray
                let unitCenter = CGPoint(x: center.x, y: center.y + 4)
                let unitRect = CGRect(
                    x: unitCenter.x - unitRadius,
                    y: unitCenter.y - unitRadius,
                    width: unitRadius * 2,
                    height: unitRadius * 2
                )

                context.stroke(Path(ellipseIn: unitRect), with: .color(.black.opacity(0.3)), lineWidth: bgStrokeWidth)
                context.fill(Path(ellipseIn: unitRect), with: .color(powerColor))
                context.stroke(Path(ellipseIn: unitRect), with: .color(.white), lineWidth: strokeWidth)

                let unitText = Text(unit.isArmy ? "A" : "F")
                    .font(.system(size: fontSize, weight: .black))
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

    private func labelOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        let currentScale = viewModel.scale
        let labelFontSize = (10.0 / currentScale).clamped(to: 5...12)

        return Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables {
                let center = CGPoint(x: territory.labelAnchor.x * w, y: territory.labelAnchor.y * h)
                let labelY = center.y - (16.0 / currentScale).clamped(to: 8...20)

                let label = Text(territory.abbreviation)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundColor(.white)
                let shadow = Text(territory.abbreviation)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))

                let labelPoint = CGPoint(x: center.x, y: labelY)
                context.draw(context.resolve(shadow), at: CGPoint(x: labelPoint.x + 0.5, y: labelPoint.y + 0.5), anchor: .center)
                context.draw(context.resolve(label), at: labelPoint, anchor: .center)
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func debugOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                context.stroke(path, with: .color(.red), lineWidth: 1)
            }

            for territory in renderables {
                let center = CGPoint(x: territory.unitAnchor.x * w, y: territory.unitAnchor.y * h)
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
}

// MARK: - Hit Testing (delegated to TerritoryHitTester)

func territoryAtPoint(_ normalizedPoint: CGPoint) -> Territory? {
    TerritoryData.hitTester.territory(at: normalizedPoint)
}
