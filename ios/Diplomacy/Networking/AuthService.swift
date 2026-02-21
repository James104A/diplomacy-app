import Foundation

actor AuthService {
    static let shared = AuthService()

    private let client = APIClient.shared

    func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        if PreviewMode.isEnabled { return MockData.authResponse }
        let request = RegisterRequest(
            provider: "email",
            email: email,
            password: password,
            displayName: displayName,
            idToken: nil
        )
        let response: AuthResponse = try await client.post("/auth/register", body: request)
        storeTokens(response)
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        if PreviewMode.isEnabled { return MockData.authResponse }
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await client.post("/auth/login", body: request)
        storeTokens(response)
        return response
    }

    func loginWithApple(idToken: String, displayName: String?) async throws -> AuthResponse {
        if PreviewMode.isEnabled { return MockData.authResponse }
        let request = AppleLoginRequest(idToken: idToken, displayName: displayName)
        let response: AuthResponse = try await client.post("/auth/login/apple", body: request)
        storeTokens(response)
        return response
    }

    func logout() {
        KeychainManager.clearAll()
    }

    func hasStoredTokens() -> Bool {
        if PreviewMode.isEnabled { return true }
        return KeychainManager.load(key: .accessToken) != nil
    }

    private func storeTokens(_ response: AuthResponse) {
        KeychainManager.save(response.accessToken, for: .accessToken)
        KeychainManager.save(response.refreshToken, for: .refreshToken)
    }
}
