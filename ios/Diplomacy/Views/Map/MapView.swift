import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    var debugMode: Bool = false

    var onTap: ((CGPoint) -> Void)?
    var onLongPress: ((CGPoint) -> Void)?

    // Gesture scratch state — local to MapView, not published
    @State private var pinchStartScale: CGFloat = 1.0
    @State private var pinchStartPan: CGPoint = .zero
    @State private var isPinching: Bool = false

    @State private var dragStartPan: CGPoint = .zero
    @State private var isDragging: Bool = false

    // MARK: - Map Aspect

    static let mapAspect: CGFloat = {
        if let img = UIImage(named: "DiplomacyMap") {
            return img.size.width / img.size.height
        }
        return 1835.0 / 1360.0
    }()

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size

            ZStack {
                // ── Map canvas ──────────────────────────────────────────────────
                // Uses a single, explicit transform: screenPt = mapPt * scale + pan
                // This is trivially invertible for hit testing, and has no SwiftUI
                // modifier-ordering ambiguity.
                Canvas { context, canvasSize in
                    let mapW = canvasSize.width
                    let mapH = mapW / MapView.mapAspect
                    let t = CGAffineTransform(translationX: viewModel.pan.x, y: viewModel.pan.y)
                        .scaledBy(x: viewModel.scale, y: viewModel.scale)

                    var ctx = context
                    ctx.transform = t

                    drawOwnershipLayer(context: &ctx, mapW: mapW, mapH: mapH)
                    drawSelectionLayer(context: &ctx, mapW: mapW, mapH: mapH)
                    drawUnitsLayer(context: &ctx, mapW: mapW, mapH: mapH)
                    if viewModel.showDetailedLabels {
                        drawLabelLayer(context: &ctx, mapW: mapW, mapH: mapH)
                    }
                    if debugMode {
                        drawDebugLayer(context: &ctx, mapW: mapW, mapH: mapH)
                    }
                }
                .background(
                    // Base map image rendered separately so Canvas can sit on top.
                    // Positioned and sized to match the Canvas transform.
                    GeometryReader { geo in
                        let mapW = geo.size.width
                        let mapH = mapW / MapView.mapAspect
                        Image("DiplomacyMap")
                            .resizable()
                            .frame(width: mapW * viewModel.scale, height: mapH * viewModel.scale)
                            .offset(x: viewModel.pan.x, y: viewModel.pan.y)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                )
                .contentShape(Rectangle())
                // Single tap
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            let normalized = viewModel.screenToNormalized(value.location, screenSize: screenSize)
                            onTap?(normalized)
                        }
                )
                // Double tap
                .onTapGesture(count: 2) {
                    viewModel.handleDoubleTap(screenSize: screenSize)
                }
                // Long press
                .highPriorityGesture(longPressGesture(screenSize: screenSize))
                // Pinch zoom
                .simultaneousGesture(magnifyGesture(screenSize: screenSize))
                // Pan
                .simultaneousGesture(panGesture(screenSize: screenSize))

                // ── Zoom buttons ────────────────────────────────────────────────
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        zoomControls(screenSize: screenSize)
                    }
                }
                .padding(.trailing, 12)
                .padding(.bottom, 12)
            }
            .clipped()
            .onAppear {
                viewModel.screenSize = screenSize
                viewModel.trySetInitialPosition()
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.screenSize = newSize
            }
        }
        .background(Color(hex: 0xB3D9FF))
    }

    // MARK: - Layer Drawing
    // All drawing uses map-pixel coordinates. The CGAffineTransform applied to the
    // context handles the scale + pan, so each layer just draws at mapPt * (mapW, mapH).

    private func drawOwnershipLayer(context: inout GraphicsContext, mapW: CGFloat, mapH: CGFloat) {
        for territory in TerritoryData.all where territory.parentTerritory == nil {
            let color = viewModel.territoryColor(for: territory)
            guard color != .clear, let poly = territory.polygon else { continue }
            let path = polygonPath(poly, mapW: mapW, mapH: mapH)
            let opacity: Double = territory.isSea ? 0.25 : 0.35
            context.fill(path, with: .color(color.opacity(opacity)))
        }
    }

    private func drawSelectionLayer(context: inout GraphicsContext, mapW: CGFloat, mapH: CGFloat) {
        for territory in TerritoryData.all where territory.parentTerritory == nil {
            guard let poly = territory.polygon else { continue }
            let isSelected = viewModel.selectedTerritory?.id == territory.id
            let isAdjacent = viewModel.showAdjacencies &&
                (viewModel.selectedTerritory.flatMap {
                    TerritoryData.adjacencies[$0.id]?.contains(territory.id)
                } ?? false)

            if isSelected {
                let path = polygonPath(poly, mapW: mapW, mapH: mapH)
                context.stroke(path, with: .color(.white), lineWidth: 1.5)
                context.stroke(path, with: .color(.yellow), lineWidth: 1.0)
            } else if isAdjacent {
                let path = polygonPath(poly, mapW: mapW, mapH: mapH)
                context.stroke(path, with: .color(.appWarning),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
        }
    }

    private func drawUnitsLayer(context: inout GraphicsContext, mapW: CGFloat, mapH: CGFloat) {
        let unitRadius: CGFloat = 5
        let fontSize: CGFloat = 6
        let scSize: CGFloat = 3
        let scOffsetY: CGFloat = 7

        // Supply center dots
        for territory in TerritoryData.all where territory.parentTerritory == nil && territory.isSupplyCenter {
            let c = CGPoint(x: territory.unitAnchor.x * mapW, y: territory.unitAnchor.y * mapH)
            let r = CGRect(x: c.x - scSize/2, y: c.y + scOffsetY, width: scSize, height: scSize)
            context.fill(Path(ellipseIn: r), with: .color(.white))
            context.stroke(Path(ellipseIn: r), with: .color(.black.opacity(0.5)), lineWidth: 0.75)
        }

        // Unit icons
        for territory in TerritoryData.all where territory.parentTerritory == nil {
            guard let unit = viewModel.unitOn(territory.id) else { continue }
            let c = CGPoint(x: territory.unitAnchor.x * mapW, y: territory.unitAnchor.y * mapH + 2)
            let powerColor = unit.powerEnum?.color(palette: viewModel.palette) ?? .gray
            let r = CGRect(x: c.x - unitRadius, y: c.y - unitRadius,
                           width: unitRadius * 2, height: unitRadius * 2)

            context.stroke(Path(ellipseIn: r), with: .color(.black.opacity(0.3)), lineWidth: 1.5)
            context.fill(Path(ellipseIn: r), with: .color(powerColor))
            context.stroke(Path(ellipseIn: r), with: .color(.white), lineWidth: 0.75)

            let label = Text(unit.isArmy ? "A" : "F")
                .font(.system(size: fontSize, weight: .black))
                .foregroundColor(.white)
            context.draw(context.resolve(label), at: c, anchor: .center)
        }
    }

    private func drawLabelLayer(context: inout GraphicsContext, mapW: CGFloat, mapH: CGFloat) {
        for territory in TerritoryData.all where territory.parentTerritory == nil {
            let c = CGPoint(x: territory.labelAnchor.x * mapW,
                            y: territory.labelAnchor.y * mapH - 8)
            let label = Text(territory.abbreviation)
                .font(.system(size: 5, weight: .bold))
                .foregroundColor(.white)
            context.draw(context.resolve(label), at: c, anchor: .center)
        }
    }

    private func drawDebugLayer(context: inout GraphicsContext, mapW: CGFloat, mapH: CGFloat) {
        for territory in TerritoryData.all where territory.parentTerritory == nil {
            guard let poly = territory.polygon else { continue }
            context.stroke(polygonPath(poly, mapW: mapW, mapH: mapH),
                           with: .color(.red), lineWidth: 0.5)
            let c = CGPoint(x: territory.unitAnchor.x * mapW, y: territory.unitAnchor.y * mapH)
            context.fill(Path(ellipseIn: CGRect(x: c.x-1.5, y: c.y-1.5, width: 3, height: 3)),
                         with: .color(.green))
        }
    }

    // MARK: - Zoom Controls

    private func zoomControls(screenSize: CGSize) -> some View {
        VStack(spacing: 4) {
            Button { viewModel.zoom(by: 1.5, screenSize: screenSize) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Button { viewModel.zoom(by: 1.0/1.5, screenSize: screenSize) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Gestures

    private func magnifyGesture(screenSize: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !isPinching {
                    pinchStartScale = viewModel.scale
                    pinchStartPan   = viewModel.pan
                    isPinching = true
                }
                let newScale = (pinchStartScale * value.magnification).clamped(to: 1.0...5.0)
                let r = newScale / pinchStartScale

                // Keep the pinch anchor fixed on screen:
                // newPan = anchor * (1 - r) + oldPan * r
                let anchor = CGPoint(
                    x: value.startAnchor.x * screenSize.width,
                    y: value.startAnchor.y * screenSize.height
                )
                let proposed = CGPoint(
                    x: anchor.x * (1 - r) + pinchStartPan.x * r,
                    y: anchor.y * (1 - r) + pinchStartPan.y * r
                )
                viewModel.scale = newScale
                viewModel.pan   = viewModel.clampPan(proposed, scale: newScale, screenSize: screenSize)
            }
            .onEnded { _ in
                isPinching = false
                viewModel.pan = viewModel.clampPan(viewModel.pan, scale: viewModel.scale, screenSize: screenSize)
            }
    }

    private func panGesture(screenSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    dragStartPan = viewModel.pan
                    isDragging = true
                }
                let proposed = CGPoint(
                    x: dragStartPan.x + value.translation.width,
                    y: dragStartPan.y + value.translation.height
                )
                viewModel.pan = viewModel.clampPan(proposed, scale: viewModel.scale, screenSize: screenSize)
            }
            .onEnded { value in
                isDragging = false
                let proposed = CGPoint(
                    x: dragStartPan.x + value.translation.width,
                    y: dragStartPan.y + value.translation.height
                )
                withAnimation(.easeOut(duration: 0.15)) {
                    viewModel.pan = viewModel.clampPan(proposed, scale: viewModel.scale, screenSize: screenSize)
                }
            }
    }

    private func longPressGesture(screenSize: CGSize) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onEnded { value in
                switch value {
                case .second(true, let drag):
                    if let location = drag?.location {
                        let normalized = viewModel.screenToNormalized(location, screenSize: screenSize)
                        onLongPress?(normalized)
                    }
                default: break
                }
            }
    }

    // MARK: - Polygon Helper

    private func polygonPath(_ vertices: [CGPoint], mapW: CGFloat, mapH: CGFloat) -> Path {
        guard vertices.count >= 3 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: vertices[0].x * mapW, y: vertices[0].y * mapH))
        for i in 1..<vertices.count {
            path.addLine(to: CGPoint(x: vertices[i].x * mapW, y: vertices[i].y * mapH))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Hit Testing

func territoryAtPoint(_ normalizedPoint: CGPoint) -> Territory? {
    TerritoryData.hitTester.territory(at: normalizedPoint)
}
