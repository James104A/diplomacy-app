import Foundation

actor MessagingService {
    static let shared = MessagingService()

    private let client = APIClient.shared

    func getConversations(gameId: UUID) async throws -> [ConversationSummary] {
        try await client.get("/games/\(gameId)/conversations")
    }

    func getMessages(conversationId: UUID, cursor: String? = nil, limit: Int = 50) async throws -> MessagePageResponse {
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: String(limit))]
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        return try await client.get("/conversations/\(conversationId)/messages", queryItems: queryItems)
    }

    func sendMessage(conversationId: UUID, content: String, replyTo: UUID? = nil) async throws -> MessageResponse {
        let request = SendMessageRequest(content: content, replyTo: replyTo)
        return try await client.post("/conversations/\(conversationId)/messages", body: request)
    }

    func markRead(conversationId: UUID, lastMessageId: UUID) async throws {
        let request = MarkReadRequest(lastMessageId: lastMessageId)
        try await client.postVoid("/conversations/\(conversationId)/read", body: request)
    }
}
