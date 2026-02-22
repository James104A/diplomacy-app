import Foundation
import SwiftUI
import Combine

// MARK: - Transform Model
//
// The map uses a single, explicit transform:
//
//   screenPt = mapPt * scale + pan
//
// where:
//   mapPt  = point in map-pixel space (0…mapW, 0…mapH)
//   scale  = current zoom level
//   pan    = where the map origin (0,0) sits in screen space
//
// Inverse (screen → map):
//   mapPt = (screenPt - pan) / scale
//
// Clamp constraints (keep map filling the screen):
//   pan.x ∈ [screenW - mapW*scale,  0]
//   pan.y ∈ [screenH - mapH*scale,  0]

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

    // Zoom & pan — the ONLY two values that drive the map transform
    @Published var scale: CGFloat = 1.0
    @Published var pan: CGPoint = .zero     // replaces offset: CGSize
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

    // MARK: - Coordinate Transform

    /// Convert a screen tap point to normalised map coordinates [0…1].
    ///
    /// Transform: screenPt = mapPt * scale + pan
    /// Inverse:   mapPt    = (screenPt - pan) / scale
    /// Normalise: normPt   = mapPt / (mapW, mapH)
    func screenToNormalized(_ screenPt: CGPoint, screenSize: CGSize) -> CGPoint {
        let mapW = screenSize.width
        let mapH = mapW / MapView.mapAspect

        let mapX = (screenPt.x - pan.x) / scale
        let mapY = (screenPt.y - pan.y) / scale

        return CGPoint(x: mapX / mapW, y: mapY / mapH)
    }

    // MARK: - Pan Clamping

    /// Clamp pan so the map always fills the screen.
    ///
    /// Transform: screenPt = mapPt * scale + pan
    ///
    /// Left edge  (mapX=0):    screenX = pan.x            must be ≤ 0
    /// Right edge (mapX=mapW): screenX = mapW*scale + pan.x  must be ≥ screenW
    /// Top edge   (mapY=0):    screenY = pan.y            must be ≤ 0
    /// Bottom edge(mapY=mapH): screenY = mapH*scale + pan.y  must be ≥ screenH
    func clampPan(_ proposed: CGPoint, scale: CGFloat, screenSize: CGSize) -> CGPoint {
        let mapW = screenSize.width
        let mapH = mapW / MapView.mapAspect

        let minX = screenSize.width  - mapW * scale   // negative when zoomed in
        let minY = screenSize.height - mapH * scale   // negative when zoomed in

        let x: CGFloat
        let y: CGFloat

        if minX >= 0 {
            x = minX / 2   // map narrower than screen — center it
        } else {
            x = proposed.x.clamped(to: minX...0)
        }

        if minY >= 0 {
            y = minY / 2   // map shorter than screen — center it
        } else {
            y = proposed.y.clamped(to: minY...0)
        }

        return CGPoint(x: x, y: y)
    }

    // MARK: - Zoom & Pan Control

    /// Called from MapView's .onAppear and .onChange(of: gameState).
    /// Only runs once, requires both screenSize and gameState to be ready.
    func trySetInitialPosition() {
        guard !didSetInitialPosition, gameState != nil, screenSize != .zero else { return }
        setInitialPosition(screenSize: screenSize)
    }

    /// Zoom to 2x, centred on the player's home supply centers.
    func setInitialPosition(screenSize: CGSize) {
        didSetInitialPosition = true
        guard let game = gameState?.game,
              let myPower = game.players.first?.power,
              let power = Power(rawValue: myPower) else { return }

        let homes = TerritoryData.all.filter { $0.homeCenter == power && $0.parentTerritory == nil }
        guard !homes.isEmpty else { return }

        let cx = homes.map(\.center.x).reduce(0, +) / CGFloat(homes.count)  // normalised 0-1
        let cy = homes.map(\.center.y).reduce(0, +) / CGFloat(homes.count)

        let mapW = screenSize.width
        let mapH = mapW / MapView.mapAspect
        let newScale: CGFloat = 2.0

        // We want: cx*mapW * scale + pan.x = screenW/2
        //          cy*mapH * scale + pan.y = screenH/2
        let proposedPan = CGPoint(
            x: screenSize.width  / 2 - cx * mapW * newScale,
            y: screenSize.height / 2 - cy * mapH * newScale
        )

        scale = newScale
        pan   = clampPan(proposedPan, scale: newScale, screenSize: screenSize)
    }

    /// Zoom around screen centre, toggling between 1x and 2.5x.
    func handleDoubleTap(screenSize: CGSize) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if scale > 1.5 {
                // Reset to 1x — pan back to origin
                scale = 1.0
                pan   = clampPan(.zero, scale: 1.0, screenSize: screenSize)
            } else {
                let newScale: CGFloat = 2.5
                let mapW = screenSize.width
                let mapH = mapW / MapView.mapAspect
                let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

                // Keep screen center fixed:
                // screenCenter = mapCenter * scale + pan
                // => pan = screenCenter - mapCenter * scale
                let mapCenterX = mapW / 2
                let mapCenterY = mapH / 2
                let proposedPan = CGPoint(
                    x: screenCenter.x - mapCenterX * newScale,
                    y: screenCenter.y - mapCenterY * newScale
                )
                scale = newScale
                pan   = clampPan(proposedPan, scale: newScale, screenSize: screenSize)
            }
        }
    }

    /// Zoom +/- buttons: zoom around the screen centre.
    func zoom(by factor: CGFloat, screenSize: CGSize) {
        let newScale = (scale * factor).clamped(to: 1.0...5.0)
        let r = newScale / scale
        let anchor = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        // Keep anchor fixed: newPan = anchor * (1 - r) + pan * r
        let proposedPan = CGPoint(
            x: anchor.x * (1 - r) + pan.x * r,
            y: anchor.y * (1 - r) + pan.y * r
        )

        withAnimation(.easeOut(duration: 0.2)) {
            scale = newScale
            pan   = clampPan(proposedPan, scale: newScale, screenSize: screenSize)
        }
    }

    // MARK: - Detail Level

    var showDetailedLabels: Bool { scale > 1.5 }
    var showUnitIcons: Bool { scale > 0.8 }
}
