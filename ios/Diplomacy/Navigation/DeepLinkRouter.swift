import Foundation

/// Handles deep link URL routing for the diplomacy:// URL scheme.
///
/// Supported routes:
/// - diplomacy://game/{id}                    → Game View (Map)
/// - diplomacy://game/{id}/messages           → Messaging Hub
/// - diplomacy://game/{id}/messages/{convId}  → Conversation View
/// - diplomacy://game/{id}/orders             → Order Entry Panel
/// - diplomacy://join/{inviteCode}            → Join Game confirmation
/// - diplomacy://profile/{playerId}           → Player Profile
enum DeepLinkRouter {

    @MainActor
    static func handle(url: URL, appState: AppState) {
        guard url.scheme == "diplomacy" else { return }

        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "game":
            handleGameLink(pathComponents: pathComponents, appState: appState)

        case "join":
            if let inviteCode = pathComponents.first {
                appState.deepLinkTab = .games
                appState.deepLinkDestination = .joinGame(inviteCode)
                appState.deepLinkInviteCode = inviteCode
            }

        case "profile":
            if let playerIdStr = pathComponents.first, let playerId = UUID(uuidString: playerIdStr) {
                appState.deepLinkTab = .social
                appState.deepLinkDestination = .playerProfile(playerId)
                appState.deepLinkPlayerId = playerId
            }

        default:
            break
        }
    }

    @MainActor
    private static func handleGameLink(pathComponents: [String], appState: AppState) {
        // Path format: /{gameId}[/messages[/{convId}]|/orders]
        guard let gameIdStr = pathComponents.first, let gameId = UUID(uuidString: gameIdStr) else {
            return
        }

        appState.deepLinkTab = .games
        appState.deepLinkGameId = gameId

        if pathComponents.count >= 2 {
            switch pathComponents[1] {
            case "messages":
                if pathComponents.count >= 3, let convId = UUID(uuidString: pathComponents[2]) {
                    appState.deepLinkDestination = .conversation(gameId, convId)
                    appState.deepLinkConversationId = convId
                } else {
                    appState.deepLinkDestination = .gameMessages(gameId)
                }

            case "orders":
                appState.deepLinkDestination = .gameOrders(gameId)

            default:
                appState.deepLinkDestination = .game(gameId)
            }
        } else {
            appState.deepLinkDestination = .game(gameId)
        }
    }
}
