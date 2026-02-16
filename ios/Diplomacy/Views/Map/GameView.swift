import SwiftUI

struct GameView: View {
    let gameId: UUID
    @EnvironmentObject var appState: AppState

    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var orderViewModel: OrderEntryViewModel

    @State private var showOrderReview = false

    init(gameId: UUID) {
        self.gameId = gameId
        _mapViewModel = StateObject(wrappedValue: MapViewModel(gameId: gameId))
        _orderViewModel = StateObject(wrappedValue: OrderEntryViewModel(gameId: gameId))
    }

    var body: some View {
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
        .navigationBarTitleDisplayMode(.inline)
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
                paletteMenu
            }
        }
    }

    private var mapContent: some View {
        ZStack {
            // Map
            MapView(viewModel: mapViewModel)
                .onTapGesture { location in
                    if orderViewModel.isActive {
                        // Handled by order entry
                    } else if mapViewModel.showTerritoryInfo {
                        mapViewModel.dismissSelection()
                    }
                }

            // Territory tap targets
            GeometryReader { geometry in
                MapTerritoryTapLayer(viewModel: mapViewModel, mapSize: geometry.size)
                    .scaleEffect(mapViewModel.scale)
                    .offset(mapViewModel.offset)
            }

            // Order arrows overlay
            if !orderViewModel.orders.isEmpty || orderViewModel.isActive {
                GeometryReader { geometry in
                    OrderArrowsOverlay(
                        orders: orderViewModel.orders,
                        activeOrder: orderViewModel.currentOrder,
                        mapSize: geometry.size,
                        palette: mapViewModel.palette
                    )
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
    }
}
