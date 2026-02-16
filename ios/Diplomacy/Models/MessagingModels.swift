import Foundation

// MARK: - Conversation Summary

struct ConversationSummary: Decodable, Identifiable {
    let id: UUID
    let type: String // "BILATERAL", "GLOBAL", "GROUP"
    let name: String?
    let participants: [ConversationParticipant]
    let lastMessage: LastMessagePreview?
    let unreadCount: Int
    let muted: Bool
    let pinned: Bool

    var displayName: String {
        if let name { return name }
        if type == "GLOBAL" { return "Global Chat" }
        // For bilateral, show the other participant's power
        return participants.first?.power ?? "Conversation"
    }

    var sortKey: (Int, Date) {
        let unreadPriority = unreadCount > 0 ? 0 : 1
        let date = lastMessage?.timestamp ?? .distantPast
        return (unreadPriority, date)
    }
}

struct ConversationParticipant: Decodable {
    let playerId: UUID
    let power: String

    var powerEnum: Power? { Power(rawValue: power) }
}

struct LastMessagePreview: Decodable {
    let senderPower: String
    let preview: String
    let timestamp: Date
    let isRead: Bool

    var senderPowerEnum: Power? { Power(rawValue: senderPower) }
}

// MARK: - Message

struct MessageResponse: Decodable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let senderPlayerId: UUID
    let senderPower: String
    let type: String // "TEXT", "MAP_ANNOTATION", "PROPOSAL"
    let content: String
    let replyTo: UUID?
    let gamePhase: String?
    let isSystem: Bool
    let createdAt: Date

    var senderPowerEnum: Power? { Power(rawValue: senderPower) }
}

struct MessagePageResponse: Decodable {
    let messages: [MessageResponse]
    let nextCursor: String?
    let hasMore: Bool
}

// MARK: - Requests

struct SendMessageRequest: Encodable {
    let type: String
    let content: String
    let replyTo: UUID?

    init(content: String, replyTo: UUID? = nil) {
        self.type = "TEXT"
        self.content = content
        self.replyTo = replyTo
    }
}

struct MarkReadRequest: Encodable {
    let lastMessageId: UUID
}
