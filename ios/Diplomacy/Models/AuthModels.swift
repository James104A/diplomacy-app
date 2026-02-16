import Foundation

// MARK: - Auth Requests

struct RegisterRequest: Encodable {
    let provider: String
    let email: String
    let password: String?
    let displayName: String
    let idToken: String?
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AppleLoginRequest: Encodable {
    let idToken: String
    let displayName: String?
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

// MARK: - Auth Response

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let player: PlayerSummary
}

struct PlayerSummary: Decodable, Identifiable {
    let id: UUID
    let displayName: String
    let elo: Int
    let reliability: Double
    let rank: String
    let createdAt: Date
}
