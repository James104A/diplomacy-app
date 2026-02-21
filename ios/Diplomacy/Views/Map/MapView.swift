import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    var debugMode: Bool = false

    var onTap: ((CGPoint) -> Void)?
    var onLongPress: ((CGPoint) -> Void)?

    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureDrag: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let mapSize = geometry.size

            ZStack {
                mapLayers(mapSize: mapSize)
                    .scaleEffect(viewModel.scale * gestureScale, anchor: .topLeading)
                    .offset(
                        x: viewModel.offset.width + gestureDrag.width,
                        y: viewModel.offset.height + gestureDrag.height
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                viewModel.handleDoubleTap(in: viewModel.screenSize)
            }
            .onTapGesture { location in
                let normalized = screenToMap(location, in: mapSize)
                onTap?(normalized)
            }
            .gesture(longPressGesture(in: mapSize))
            .simultaneousGesture(pinchGesture)
            .simultaneousGesture(panGesture)
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

    static let mapAspect: CGFloat = {
        if let uiImage = UIImage(named: "DiplomacyMap") {
            return uiImage.size.width / uiImage.size.height
        }
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

    /// Convert a screen tap point to normalized [0..1] map coordinates.
    ///
    /// The map is rendered at top-left (0,0) of the GeometryReader, then
    /// transformed by .scaleEffect(anchor: .topLeading) + .offset.
    /// To invert: subtract offset first, then divide by scale.
    private func screenToMap(_ screenPoint: CGPoint, in viewSize: CGSize) -> CGPoint {
        let mapHeight = viewSize.width / Self.mapAspect
        let currentScale = viewModel.scale * gestureScale
        let currentOffset = CGSize(
            width: viewModel.offset.width + gestureDrag.width,
            height: viewModel.offset.height + gestureDrag.height
        )

        // Invert the transform: point_in_map = (screen_point - offset) / scale
        let mapX = (screenPoint.x - currentOffset.width) / currentScale
        let mapY = (screenPoint.y - currentOffset.height) / currentScale

        // Normalize to [0..1]
        return CGPoint(x: mapX / viewSize.width, y: mapY / mapHeight)
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
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
    }

    private var panGesture: some Gesture {
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
    }

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
        let unitRadius: CGFloat = 11
        let fontSize: CGFloat = 12
        let strokeWidth: CGFloat = 1.5
        let bgStrokeWidth: CGFloat = 3.0
        let scSize: CGFloat = 6
        let scOffset: CGFloat = 12

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
                context.draw(context.resolve(unitText), at: unitCenter, anchor: .center)
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func labelOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        let labelFontSize: CGFloat = 10

        return Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables {
                let center = CGPoint(x: territory.labelAnchor.x * w, y: territory.labelAnchor.y * h)
                let labelY = center.y - 16
                let labelPoint = CGPoint(x: center.x, y: labelY)

                let shadow = Text(territory.abbreviation)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))
                let label = Text(territory.abbreviation)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundColor(.white)

                context.draw(context.resolve(shadow), at: CGPoint(x: labelPoint.x + 0.5, y: labelPoint.y + 0.5), anchor: .center)
                context.draw(context.resolve(label), at: labelPoint, anchor: .center)
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func debugOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        Canvas { context, size in
            for territory in TerritoryData.all.filter({ $0.parentTerritory == nil }) {
                guard let poly = territory.polygon else { continue }
                let path = polygonPath(poly, width: w, height: h)
                context.stroke(path, with: .color(.red), lineWidth: 1)
                let center = CGPoint(x: territory.unitAnchor.x * w, y: territory.unitAnchor.y * h)
                let dotRect = CGRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5)
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

// MARK: - Hit Testing

func territoryAtPoint(_ normalizedPoint: CGPoint) -> Territory? {
    TerritoryData.hitTester.territory(at: normalizedPoint)
}
