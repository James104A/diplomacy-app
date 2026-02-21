import SwiftUI

struct GameView: View {
    let gameId: UUID
    @EnvironmentObject var appState: AppState

    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var orderViewModel: OrderEntryViewModel

    @State private var showOrderReview = false
    @State private var showMessaging = false

    init(gameId: UUID) {
        self.gameId = gameId
        _mapViewModel = StateObject(wrappedValue: MapViewModel(gameId: gameId))
        _orderViewModel = StateObject(wrappedValue: OrderEntryViewModel(gameId: gameId))
    }

    var body: some View {
        VStack(spacing: 0) {
            OfflineBanner()

            ZStack {
            if mapViewModel.isLoading {
                ProgressView("Loading game...")
            } else if let error = mapViewModel.errorMessage {
                VStack(spacing: Spacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.appError)
                    Text(error)
                        .font(.appSecondary)
                        .foregroundColor(.appSecondary)
                    DiplomacyButton(title: "Retry", style: .primary) {
                        Task { await mapViewModel.loadGameState() }
                    }
                    .frame(width: 200)
                }
            } else {
                mapContent
            }
            }
            .frame(maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await mapViewModel.loadGameState()
            mapViewModel.subscribeToWebSocket()
        }
        .navigationDestination(isPresented: $showMessaging) {
            if let game = mapViewModel.gameState?.game {
                let myPower = game.players.first?.power ?? ""
                MessagingHubView(
                    gameId: gameId,
                    myPower: myPower,
                    palette: mapViewModel.palette
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let game = mapViewModel.gameState?.game {
                    VStack(spacing: 0) {
                        Text(game.name)
                            .font(.appSecondaryBold)
                        Text("\(game.currentSeason.capitalized) \(game.currentYear)")
                            .font(.appCaption)
                            .foregroundColor(.appSecondary)
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    Button {
                        showMessaging = true
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right")
                    }
                    .accessibilityLabel("Messages")

                    paletteMenu
                }
            }
        }
    }

    private var mapContent: some View {
        ZStack {
            // Map
            MapView(viewModel: mapViewModel, debugMode: true)

            // Transparent tap overlay — converts screen taps to map coordinates
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let normalized = screenToMap(location, in: geometry.size)
                        if let territory = territoryAtPoint(normalized) {
                            handleTerritoryTap(territory)
                        } else if mapViewModel.showTerritoryInfo {
                            mapViewModel.dismissSelection()
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if let location = drag?.location {
                                        let normalized = screenToMap(location, in: geometry.size)
                                        if let territory = territoryAtPoint(normalized) {
                                            mapViewModel.longPressTerritory(territory)
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                    )
            }

            // Order arrows overlay
            if !orderViewModel.orders.isEmpty || orderViewModel.isActive {
                GeometryReader { geometry in
                    let mapCanvasSize = CGSize(
                        width: geometry.size.width,
                        height: geometry.size.width / MapView.mapAspect
                    )
                    OrderArrowsOverlay(
                        orders: orderViewModel.orders,
                        activeOrder: orderViewModel.currentOrder,
                        mapSize: mapCanvasSize,
                        palette: mapViewModel.palette
                    )
                    // Center the overlay in the full view, matching MapView's ZStack centering
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(mapViewModel.scale)
                    .offset(mapViewModel.offset)
                    .allowsHitTesting(false)
                }
            }

            // Order palette (floating near selected unit)
            if orderViewModel.showOrderPalette, let unit = orderViewModel.selectedUnit {
                OrderPaletteView(
                    unit: unit,
                    availableOrders: orderViewModel.availableOrderTypes,
                    onSelect: { orderType in
                        orderViewModel.selectOrderType(orderType)
                    },
                    onCancel: {
                        orderViewModel.cancelOrder()
                    }
                )
            }

            // Bottom bar
            VStack {
                Spacer()
                bottomBar
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: Spacing.sm) {
            if let game = mapViewModel.gameState?.game, let deadline = game.phaseDeadline {
                DeadlineTimerView(deadline: deadline)
            }

            Spacer()

            if !orderViewModel.orders.isEmpty {
                Button {
                    showOrderReview = true
                } label: {
                    Label("Review (\(orderViewModel.orders.count))", systemImage: "list.bullet")
                        .font(.appSecondaryBold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.appPrimary)
                        .cornerRadius(Spacing.xs)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showOrderReview) {
            OrderReviewView(viewModel: orderViewModel, palette: mapViewModel.palette)
        }
    }

    private var paletteMenu: some View {
        Menu {
            ForEach(PowerPalette.allCases, id: \.self) { p in
                Button {
                    mapViewModel.palette = p
                } label: {
                    HStack {
                        Text(p.rawValue.capitalized)
                        if mapViewModel.palette == p {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            Divider()

            Toggle("Pattern Overlays", isOn: $mapViewModel.showPatterns)
        } label: {
            Image(systemName: "paintpalette")
        }
        .accessibilityLabel("Color palette")
    }

    // MARK: - Coordinate Conversion

    /// Convert a screen tap location to normalized 0-1 map coordinates,
    /// accounting for current zoom (scale) and pan (offset).
    private func screenToMap(_ screenPoint: CGPoint, in viewSize: CGSize) -> CGPoint {
        let mapHeight = viewSize.width / MapView.mapAspect
        // Reverse the offset and scale transforms applied to the map canvas.
        // Scale is anchored at the view center (viewSize/2). After unscaling,
        // convert from parent coords to map-local coords by accounting for the
        // vertical centering offset: map top-left is at y = (viewHeight - mapHeight)/2.
        let x = (screenPoint.x - viewSize.width / 2 - mapViewModel.offset.width) / mapViewModel.scale + viewSize.width / 2
        let y = (screenPoint.y - viewSize.height / 2 - mapViewModel.offset.height) / mapViewModel.scale + mapHeight / 2
        // Normalize to 0-1 range against actual map canvas dimensions
        return CGPoint(x: x / viewSize.width, y: y / mapHeight)
    }

    // MARK: - Territory Tap Handling

    private func handleTerritoryTap(_ territory: Territory) {
        if orderViewModel.isActive, orderViewModel.selectedOrderType != nil {
            // We're choosing a destination — only allow valid ones
            let valid = orderViewModel.validDestinations(units: mapViewModel.gameState?.units ?? [])
            guard valid.contains(territory.id) else { return }
            orderViewModel.selectDestination(territory.id)
        } else if orderViewModel.isActive {
            // Unit selected but no order type yet — tapping elsewhere cancels
            orderViewModel.cancelOrder()
            mapViewModel.selectTerritory(territory)
        } else if let unit = mapViewModel.unitOn(territory.id), isMyUnit(unit) {
            // Tapped one of our own units — start order entry
            orderViewModel.selectUnit(unit)
            mapViewModel.selectTerritory(territory)
        } else {
            // Tapped a territory with no friendly unit — show info
            mapViewModel.selectTerritory(territory)
        }
    }

    private func isMyUnit(_ unit: UnitDto) -> Bool {
        guard let game = mapViewModel.gameState?.game else { return false }
        // In the dashboard, the game summary tells us our power.
        // From GameStateResponse, the first player is typically "us" (the requesting player).
        let myPower = game.players.first?.power
        return unit.power == myPower
    }
}
