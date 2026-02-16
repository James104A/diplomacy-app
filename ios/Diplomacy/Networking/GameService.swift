import Foundation

actor GameService {
    static let shared = GameService()

    private let client = APIClient.shared

    func getMyGames() async throws -> [GameSummary] {
        try await client.get("/players/me/games")
    }

    func createGame(_ request: CreateGameRequest) async throws -> GameResponse {
        try await client.post("/games", body: request)
    }

    func getGame(id: UUID) async throws -> GameResponse {
        try await client.get("/games/\(id)")
    }

    func getGameByInviteCode(_ inviteCode: String) async throws -> GameResponse {
        try await client.get("/games/invite/\(inviteCode)")
    }

    func joinGame(inviteCode: String) async throws -> GameResponse {
        try await client.post("/games/join/\(inviteCode)")
    }

    func joinGame(id: UUID) async throws -> GameResponse {
        try await client.post("/games/\(id)/join")
    }
}
