import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var gamesNeedingAttention = 0
    @Published var pendingFriendRequests = 0

    // Deep link routing
    @Published var deepLinkTab: AppTab?
    @Published var deepLinkGameId: UUID?
    @Published var deepLinkConversationId: UUID?
    @Published var deepLinkInviteCode: String?
    @Published var deepLinkPlayerId: UUID?
    @Published var deepLinkDestination: DeepLinkDestination?
}

enum DeepLinkDestination {
    case game(UUID)
    case gameMessages(UUID)
    case conversation(UUID, UUID)
    case gameOrders(UUID)
    case joinGame(String)
    case playerProfile(UUID)
}
