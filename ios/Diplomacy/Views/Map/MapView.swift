import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    var debugMode: Bool = false

    var onTap: ((CGPoint) -> Void)?
    var onLongPress: ((CGPoint) -> Void)?

    // Pinch state — written directly by MagnifyGesture callbacks
    @State private var pinchStartScale: CGFloat = 1.0
    @State private var pinchStartOffset: CGSize = .zero
    @State private var isPinching: Bool = false

    // Pan state — written directly by DragGesture callbacks (like magnify)
    @State private var dragStartOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let mapSize = geometry.size

            ZStack {
                // Map content with transforms
                ZStack {
                    mapLayers(mapSize: mapSize)
                        .scaleEffect(viewModel.scale, anchor: .topLeading)
                        .offset(viewModel.offset)
                }
                .frame(width: mapSize.width, height: mapSize.height)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    viewModel.handleDoubleTap(in: viewModel.screenSize)
                }
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            let normalized = screenToMap(value.location, in: mapSize)
                            onTap?(normalized)
                        }
                )
                .highPriorityGesture(longPressGesture(in: mapSize))
                .simultaneousGesture(magnifyGesture(in: mapSize))
                .simultaneousGesture(panGesture)

                // Zoom controls (not affected by map transforms)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        zoomControls
                    }
                }
                .padding(.trailing, 12)
                .padding(.bottom, 12)
            }
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

    // MARK: - Zoom Controls

    /// Zoom keeping screen center fixed: newOffset = offset * r + center * (1 - r)
    private func zoomAround(factor: CGFloat) {
        let oldScale = viewModel.scale
        let newScale = (oldScale * factor).clamped(to: 1.0...5.0)
        let r = newScale / oldScale
        let center = CGPoint(
            x: viewModel.screenSize.width / 2,
            y: viewModel.screenSize.height / 2
        )
        let proposedOffset = CGSize(
            width:  viewModel.offset.width  * r + (1 - r) * center.x,
            height: viewModel.offset.height * r + (1 - r) * center.y
        )
        withAnimation(.easeOut(duration: 0.2)) {
            viewModel.scale = newScale
            viewModel.offset = viewModel.clampOffset(
                proposedOffset, scale: newScale, screenSize: viewModel.screenSize
            )
        }
    }

    private var zoomControls: some View {
        VStack(spacing: 4) {
            Button { zoomAround(factor: 1.5) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button { zoomAround(factor: 1.0 / 1.5) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
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
        let currentScale = viewModel.scale
        let currentOffset = viewModel.offset

        // Invert the transform: point_in_map = (screen_point - offset) / scale
        let mapX = (screenPoint.x - currentOffset.width) / currentScale
        let mapY = (screenPoint.y - currentOffset.height) / currentScale

        // Normalize to [0..1]
        return CGPoint(x: mapX / viewSize.width, y: mapY / mapHeight)
    }

    // MARK: - Gestures

    /// Anchored pinch-to-zoom using iOS 17+ MagnifyGesture.
    /// The pinch center stays fixed under the user's fingers.
    private func magnifyGesture(in mapSize: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !isPinching {
                    pinchStartScale = viewModel.scale
                    pinchStartOffset = viewModel.offset
                    isPinching = true
                }

                let targetScale = (pinchStartScale * value.magnification).clamped(to: 1.0...5.0)

                // Convert the gesture's startAnchor (UnitPoint 0-1) to a screen point
                let anchorPt = CGPoint(
                    x: value.startAnchor.x * mapSize.width,
                    y: value.startAnchor.y * mapSize.height
                )

                // Adjust offset so the anchor stays stationary as scale changes
                let r = targetScale / pinchStartScale
                let proposedOffset = CGSize(
                    width:  r * pinchStartOffset.width  + (1 - r) * anchorPt.x,
                    height: r * pinchStartOffset.height + (1 - r) * anchorPt.y
                )

                viewModel.scale = targetScale
                viewModel.offset = viewModel.clampOffset(
                    proposedOffset, scale: targetScale, screenSize: viewModel.screenSize
                )
            }
            .onEnded { _ in
                isPinching = false
                viewModel.offset = viewModel.clampOffset(
                    viewModel.offset, scale: viewModel.scale, screenSize: viewModel.screenSize
                )
            }
    }

    /// Pan gesture — writes directly to viewModel.offset in onChanged,
    /// then clamps with animation on release.
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    dragStartOffset = viewModel.offset
                    isDragging = true
                }
                viewModel.offset = CGSize(
                    width: dragStartOffset.width + value.translation.width,
                    height: dragStartOffset.height + value.translation.height
                )
            }
            .onEnded { value in
                isDragging = false
                let proposed = CGSize(
                    width: dragStartOffset.width + value.translation.width,
                    height: dragStartOffset.height + value.translation.height
                )
                withAnimation(.easeOut(duration: 0.15)) {
                    viewModel.offset = viewModel.clampOffset(
                        proposed, scale: viewModel.scale, screenSize: viewModel.screenSize
                    )
                }
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
                    context.stroke(path, with: .color(.white), lineWidth: 1.5)
                    context.stroke(path, with: .color(.yellow), lineWidth: 1)
                } else if isAdjacent {
                    let path = polygonPath(poly, width: w, height: h)
                    context.stroke(path, with: .color(.appWarning), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func interactiveOverlay(width w: CGFloat, height h: CGFloat) -> some View {
        let unitRadius: CGFloat = 5
        let fontSize: CGFloat = 6
        let strokeWidth: CGFloat = 0.75
        let bgStrokeWidth: CGFloat = 1.5
        let scSize: CGFloat = 3
        let scOffset: CGFloat = 7

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
                let unitCenter = CGPoint(x: center.x, y: center.y + 2)
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
        let labelFontSize: CGFloat = 5

        return Canvas { context, size in
            let renderables = TerritoryData.all.filter { $0.parentTerritory == nil }

            for territory in renderables {
                let center = CGPoint(x: territory.labelAnchor.x * w, y: territory.labelAnchor.y * h)
                let labelY = center.y - 8
                let labelPoint = CGPoint(x: center.x, y: labelY)

                let label = Text(territory.abbreviation)
                    .font(.system(size: labelFontSize, weight: .bold))
                    .foregroundColor(.white)

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
                context.stroke(path, with: .color(.red), lineWidth: 0.5)
                let center = CGPoint(x: territory.unitAnchor.x * w, y: territory.unitAnchor.y * h)
                let dotRect = CGRect(x: center.x - 1.5, y: center.y - 1.5, width: 3, height: 3)
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
