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
                        width: viewModel.offset.width + gestureDrag.width,
                        height: viewModel.offset.height + gestureDrag.height
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
            let mapWidth = size.width
            let mapHeight = size.height

            // Draw territories
            for territory in TerritoryData.all where territory.parentTerritory == nil {
                let center = CGPoint(
                    x: territory.center.x * mapWidth,
                    y: territory.center.y * mapHeight
                )

                let isSelected = viewModel.selectedTerritory?.id == territory.id
                let isAdjacent = viewModel.showAdjacencies &&
                    viewModel.selectedTerritory.flatMap { TerritoryData.adjacencies[$0.id]?.contains(territory.id) } ?? false

                // Territory fill circle (simplified rendering)
                let radius: CGFloat = territory.isSea ? 22 : 28
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )

                let fillColor = viewModel.territoryColor(for: territory)
                let path = territory.isSea ?
                    Path(ellipseIn: rect) :
                    Path(roundedRect: rect, cornerRadius: 6)

                context.fill(path, with: .color(fillColor.opacity(territory.isSea ? 0.3 : 0.8)))

                // Selection highlight
                if isSelected {
                    context.stroke(path, with: .color(.white), lineWidth: 3)
                    context.stroke(path, with: .color(.appPrimary), lineWidth: 2)
                } else if isAdjacent {
                    context.stroke(path, with: .color(.appWarning), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                }

                // Supply center marker
                if territory.isSupplyCenter {
                    let scSize: CGFloat = 6
                    let scRect = CGRect(
                        x: center.x - scSize / 2,
                        y: center.y + radius - scSize - 2,
                        width: scSize,
                        height: scSize
                    )
                    context.fill(Path(ellipseIn: scRect), with: .color(.white))
                    context.stroke(Path(ellipseIn: scRect), with: .color(.black.opacity(0.5)), lineWidth: 0.5)
                }

                // Territory abbreviation
                let showLabel = viewModel.showDetailedLabels || !territory.isSea
                if showLabel {
                    let text = Text(territory.abbreviation)
                        .font(.system(size: viewModel.showDetailedLabels ? 10 : 8, weight: .bold))
                        .foregroundColor(territory.isSea ? .blue.opacity(0.6) : .black.opacity(0.7))
                    context.draw(
                        context.resolve(text),
                        at: CGPoint(x: center.x, y: center.y - radius + 10),
                        anchor: .center
                    )
                }

                // Unit icon
                if viewModel.showUnitIcons, let unit = viewModel.unitOn(territory.id) {
                    let unitSymbol = unit.isArmy ? "shield.fill" : "sailboat.fill"
                    if let powerColor = unit.powerEnum?.color(palette: viewModel.palette) {
                        let unitText = Text(unit.isArmy ? "A" : "F")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                        context.draw(
                            context.resolve(unitText),
                            at: center,
                            anchor: .center
                        )
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { location in
            handleTap(at: location, in: .zero) // Will be handled by overlay
        }
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

    // MARK: - Hit Testing

    private func handleTap(at location: CGPoint, in size: CGSize) {
        // Hit test handled by territory overlay buttons
    }
}

// MARK: - Territory Tap Overlay

struct MapTerritoryTapLayer: View {
    @ObservedObject var viewModel: MapViewModel
    let mapSize: CGSize

    var body: some View {
        ForEach(TerritoryData.all.filter { $0.parentTerritory == nil }) { territory in
            let center = CGPoint(
                x: territory.center.x * mapSize.width,
                y: territory.center.y * mapSize.height
            )

            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .position(center)
                .onTapGesture {
                    viewModel.selectTerritory(territory)
                }
                .onLongPressGesture {
                    viewModel.longPressTerritory(territory)
                }
        }
    }
}
