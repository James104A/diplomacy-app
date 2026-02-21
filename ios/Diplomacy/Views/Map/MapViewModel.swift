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

    // Zoom
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGSize = .zero

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

    // MARK: - Detail Level

    var showDetailedLabels: Bool {
        scale > 1.5
    }

    var showUnitIcons: Bool {
        scale > 0.8
    }
}
