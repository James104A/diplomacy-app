import Foundation
import SwiftUI
import Combine

@MainActor
class MapViewModel: ObservableObject {
    let gameId: UUID

    @Published var gameState: GameStateResponse?
    @Published var isLoading = true
    @Published var errorMessage: String?

    // Map interaction
    @Published var selectedTerritory: Territory?
    @Published var showTerritoryInfo = false
    @Published var showAdjacencies = false

    // Color-blind settings
    @Published var palette: PowerPalette = .classic
    @Published var showPatterns = false

    // Zoom & pan
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    @Published var screenSize: CGSize = .zero
    private var didSetInitialPosition = false

    private var cancellables = Set<AnyCancellable>()

    init(gameId: UUID) {
        self.gameId = gameId
    }

    // MARK: - Data Loading

    func loadGameState() async {
        isLoading = gameState == nil
        errorMessage = nil

        do {
            gameState = try await GameService.shared.getGameState(id: gameId)
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load game."
        }
        isLoading = false
    }

    func subscribeToWebSocket() {
        WebSocketManager.shared.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard event.gameId == self?.gameId.uuidString else { return }
                if event.event == "game.phase_resolved" || event.event == "game.orders_submitted" {
                    Task { await self?.loadGameState() }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Territory State

    func ownerPower(for territoryId: String) -> Power? {
        guard let scs = gameState?.supplyCenters else { return nil }
        if let ownerStr = scs[territoryId], let owner = ownerStr {
            return Power(rawValue: owner)
        }
        // Check if a unit is on this territory — that power "occupies" it
        if let unit = unitOn(territoryId) {
            return unit.powerEnum
        }
        return nil
    }

    func unitOn(_ territoryId: String) -> UnitDto? {
        gameState?.units.first { $0.territoryId == territoryId }
    }

    func isSupplyCenter(_ territoryId: String) -> Bool {
        gameState?.supplyCenters.keys.contains(territoryId) ?? false
    }

    func territoryColor(for territory: Territory) -> Color {
        if let power = ownerPower(for: territory.id) {
            return power.color(palette: palette)
        }
        // Unowned territories: no overlay — base map image shows through
        return .clear
    }

    // MARK: - Territory Selection

    func selectTerritory(_ territory: Territory) {
        if selectedTerritory?.id == territory.id {
            selectedTerritory = nil
            showTerritoryInfo = false
            showAdjacencies = false
        } else {
            selectedTerritory = territory
            showTerritoryInfo = true
            showAdjacencies = false
        }
    }

    func longPressTerritory(_ territory: Territory) {
        selectedTerritory = territory
        showAdjacencies = true
        showTerritoryInfo = true
    }

    func dismissSelection() {
        selectedTerritory = nil
        showTerritoryInfo = false
        showAdjacencies = false
    }

    // MARK: - Zoom & Pan

    /// Try to set initial position — called from both .task and .onChange(of: screenSize).
    /// Only runs once, requires both gameState and screenSize to be available.
    func trySetInitialPosition() {
        guard !didSetInitialPosition, gameState != nil, screenSize != .zero else { return }
        setInitialPosition(screenSize: screenSize)
    }

    /// Set initial position centered on the player's home supply centers at 2x zoom.
    /// Assumes .scaleEffect(anchor: .topLeading) — origin is top-left of map.
    func setInitialPosition(screenSize: CGSize) {
        didSetInitialPosition = true
        guard let game = gameState?.game,
              let myPower = game.players.first?.power,
              let power = Power(rawValue: myPower) else { return }

        let homeCenters = TerritoryData.all.filter { $0.homeCenter == power && $0.parentTerritory == nil }
        guard !homeCenters.isEmpty else { return }

        let cx = homeCenters.map(\.center.x).reduce(0, +) / CGFloat(homeCenters.count)
        let cy = homeCenters.map(\.center.y).reduce(0, +) / CGFloat(homeCenters.count)

        let newScale: CGFloat = 2.0
        let mapHeight = screenSize.width / MapView.mapAspect

        // With topLeading anchor: scaled point is at (point * scale + offset)
        // We want (cx * mapWidth * scale + offsetX) == screenWidth / 2
        // So offsetX = screenWidth/2 - cx * mapWidth * scale
        let offsetX = screenSize.width / 2 - cx * screenSize.width * newScale
        let offsetY = screenSize.height / 2 - cy * mapHeight * newScale

        scale = newScale
        offset = clampOffset(CGSize(width: offsetX, height: offsetY), scale: newScale, screenSize: screenSize)
    }

    /// Clamp offset so the map stays on screen.
    /// Assumes .scaleEffect(anchor: .topLeading).
    ///
    /// - containerSize: the GeometryReader size (stored as screenSize)
    /// - mapBaseSize: the unscaled map content size (width = container width,
    ///   height = container width / mapAspect)
    func clampOffset(_ proposed: CGSize, scale: CGFloat, screenSize: CGSize) -> CGSize {
        let containerW = screenSize.width
        let containerH = screenSize.height
        let contentW   = containerW * scale
        let contentH   = (containerW / MapView.mapAspect) * scale

        let offsetX: CGFloat
        let offsetY: CGFloat

        if contentW <= containerW {
            offsetX = (containerW - contentW) / 2
        } else {
            let minX = containerW - contentW  // negative
            let maxX: CGFloat = 0
            offsetX = proposed.width.clamped(to: minX...maxX)
        }

        if contentH <= containerH {
            offsetY = (containerH - contentH) / 2
        } else {
            let minY = containerH - contentH  // negative
            let maxY: CGFloat = 0
            offsetY = proposed.height.clamped(to: minY...maxY)
        }

        return CGSize(width: offsetX, height: offsetY)
    }

    /// Toggle zoom on double-tap, centering on screen center.
    func handleDoubleTap(in screenSize: CGSize) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if scale > 1.5 {
                scale = 1.0
                offset = .zero
            } else {
                let newScale: CGFloat = 2.5
                // Keep center of screen fixed during zoom
                let offsetX = screenSize.width  / 2 - (screenSize.width  / 2) * newScale
                let offsetY = screenSize.height / 2 - (screenSize.height / 2) * newScale
                scale = newScale
                offset = clampOffset(CGSize(width: offsetX, height: offsetY),
                                     scale: newScale, screenSize: screenSize)
            }
        }
    }

    // MARK: - Detail Level

    var showDetailedLabels: Bool {
        scale > 1.5
    }

    var showUnitIcons: Bool {
        scale > 0.8
    }
}
