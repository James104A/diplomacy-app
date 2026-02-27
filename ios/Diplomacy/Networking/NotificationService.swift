import Foundation

actor NotificationService {
    static let shared = NotificationService()

    private let client = APIClient.shared

    func getPreferences() async throws -> NotificationPreferences {
        if PreviewMode.isEnabled { return MockData.notificationPreferences }
        return try await client.get("/players/me/notifications")
    }

    func updatePreferences(_ prefs: NotificationPreferences) async throws -> NotificationPreferences {
        if PreviewMode.isEnabled { return prefs }
        return try await client.put("/players/me/notifications", body: prefs)
    }
}
