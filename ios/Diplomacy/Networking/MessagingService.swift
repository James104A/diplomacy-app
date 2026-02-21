import Foundation

actor MessagingService {
    static let shared = MessagingService()

    private let client = APIClient.shared

    func getConversations(gameId: UUID) async throws -> [ConversationSummary] {
        if PreviewMode.isEnabled { return MockData.conversations(gameId: gameId) }
        return try await client.get("/games/\(gameId)/conversations")
    }

    func getMessages(conversationId: UUID, cursor: String? = nil, limit: Int = 50) async throws -> MessagePageResponse {
        if PreviewMode.isEnabled { return MockData.messages(conversationId: conversationId) }
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: String(limit))]
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        return try await client.get("/conversations/\(conversationId)/messages", queryItems: queryItems)
    }

    func sendMessage(conversationId: UUID, content: String, replyTo: UUID? = nil) async throws -> MessageResponse {
        if PreviewMode.isEnabled { return MockData.sentMessage(conversationId: conversationId, content: content) }
        let request = SendMessageRequest(content: content, replyTo: replyTo)
        return try await client.post("/conversations/\(conversationId)/messages", body: request)
    }

    func markRead(conversationId: UUID, lastMessageId: UUID) async throws {
        if PreviewMode.isEnabled { return }
        let request = MarkReadRequest(lastMessageId: lastMessageId)
        try await client.postVoid("/conversations/\(conversationId)/read", body: request)
    }
}
