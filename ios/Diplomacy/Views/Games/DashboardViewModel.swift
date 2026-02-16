import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var games: [GameSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    var sortedGames: [GameSummary] {
        games.sorted { $0.cardState < $1.cardState }
    }

    var attentionCount: Int {
        games.filter { $0.cardState == .needsOrders || $0.cardState == .unreadMessages }.count
    }

    func loadGames() async {
        isLoading = games.isEmpty
        errorMessage = nil

        do {
            games = try await GameService.shared.getMyGames()
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load games."
        }

        isLoading = false
    }

    func subscribeToWebSocket() {
        WebSocketManager.shared.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleWebSocketEvent(event)
            }
            .store(in: &cancellables)
    }

    private func handleWebSocketEvent(_ event: WebSocketEvent) {
        switch event.event {
        case "game.phase_resolved", "game.started", "game.ended":
            Task { await loadGames() }

        case "message.new":
            guard let gameIdStr = event.gameId,
                  let gameId = UUID(uuidString: gameIdStr) else { return }
            if let index = games.firstIndex(where: { $0.gameId == gameId }) {
                // Increment unread count locally for responsiveness
                var updated = games[index]
                games[index] = GameSummary(
                    gameId: updated.gameId,
                    name: updated.name,
                    status: updated.status,
                    power: updated.power,
                    currentPhase: updated.currentPhase,
                    currentSeason: updated.currentSeason,
                    currentYear: updated.currentYear,
                    phaseDeadline: updated.phaseDeadline,
                    ordersSubmitted: updated.ordersSubmitted,
                    supplyCenterCount: updated.supplyCenterCount,
                    prevSupplyCenterCount: updated.prevSupplyCenterCount,
                    unreadMessageCount: updated.unreadMessageCount + 1,
                    playerCount: updated.playerCount
                )
            }

        case "game.player_joined":
            guard let gameIdStr = event.gameId,
                  let gameId = UUID(uuidString: gameIdStr) else { return }
            if let index = games.firstIndex(where: { $0.gameId == gameId }) {
                var updated = games[index]
                games[index] = GameSummary(
                    gameId: updated.gameId,
                    name: updated.name,
                    status: updated.status,
                    power: updated.power,
                    currentPhase: updated.currentPhase,
                    currentSeason: updated.currentSeason,
                    currentYear: updated.currentYear,
                    phaseDeadline: updated.phaseDeadline,
                    ordersSubmitted: updated.ordersSubmitted,
                    supplyCenterCount: updated.supplyCenterCount,
                    prevSupplyCenterCount: updated.prevSupplyCenterCount,
                    unreadMessageCount: updated.unreadMessageCount,
                    playerCount: updated.playerCount + 1
                )
            }

        default:
            break
        }
    }
}
