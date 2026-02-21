import Foundation

actor GameService {
    static let shared = GameService()

    private let client = APIClient.shared

    func getMyGames() async throws -> [GameSummary] {
        if PreviewMode.isEnabled { return MockData.gameSummaries }
        return try await client.get("/players/me/games")
    }

    func createGame(_ request: CreateGameRequest) async throws -> GameResponse {
        if PreviewMode.isEnabled { return MockData.gameState.game }
        return try await client.post("/games", body: request)
    }

    func getGame(id: UUID) async throws -> GameResponse {
        if PreviewMode.isEnabled { return MockData.gameState.game }
        return try await client.get("/games/\(id)")
    }

    func getGameByInviteCode(_ inviteCode: String) async throws -> GameResponse {
        if PreviewMode.isEnabled { return MockData.gameState.game }
        return try await client.get("/games/invite/\(inviteCode)")
    }

    func joinGame(inviteCode: String) async throws -> GameResponse {
        if PreviewMode.isEnabled { return MockData.gameState.game }
        return try await client.post("/games/join/\(inviteCode)")
    }

    func joinGame(id: UUID) async throws -> GameResponse {
        if PreviewMode.isEnabled { return MockData.gameState.game }
        return try await client.post("/games/\(id)/join")
    }

    func getGameState(id: UUID) async throws -> GameStateResponse {
        if PreviewMode.isEnabled { return MockData.gameState }
        return try await client.get("/games/\(id)")
    }

    func submitOrders(gameId: UUID, orders: [OrderDto]) async throws -> OrderSubmissionResponse {
        if PreviewMode.isEnabled { return MockData.orderSubmissionResponse }
        let request = SubmitOrdersRequest(orders: orders)
        return try await client.put("/games/\(gameId)/orders", body: request)
    }
}
