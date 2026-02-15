package com.diplomacy.messaging

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.time.Instant
import java.util.UUID

// ================================================================
// CONVERSATIONS
// ================================================================

data class ConversationSummary(
    val id: UUID,
    val type: String,
    val name: String?,
    val participants: List<String>, // power names
    val lastMessage: LastMessagePreview?,
    val unreadCount: Long,
    val isMuted: Boolean,
    val isPinned: Boolean
)

data class LastMessagePreview(
    val senderPower: String,
    val preview: String,
    val sentAt: Instant,
    val read: Boolean
)

data class ConversationListResponse(
    val conversations: List<ConversationSummary>
)

data class CreateGroupChatRequest(
    @field:Size(min = 2, max = 7)
    val participants: List<String>, // power names
    @field:Size(max = 100)
    val name: String? = null
)

// ================================================================
// MESSAGES
// ================================================================

data class SendMessageRequest(
    @field:NotBlank
    val type: String, // TEXT, MAP_ANNOTATION, PROPOSAL
    val content: String, // JSON string for TEXT: {"text":"..."}, or structured for MAP_ANNOTATION/PROPOSAL
    val replyTo: UUID? = null
)

data class MessageResponse(
    val id: UUID,
    val conversationId: UUID,
    val senderPlayerId: UUID,
    val senderPower: String,
    val type: String,
    val content: String, // JSONB content as-is
    val replyToId: UUID?,
    val gamePhase: String,
    val isSystem: Boolean,
    val sentAt: Instant
)

data class MessagePageResponse(
    val messages: List<MessageResponse>,
    val nextCursor: UUID?,
    val hasMore: Boolean
)

// ================================================================
// PROPOSALS
// ================================================================

data class ProposalResponse(
    val id: UUID,
    val messageId: UUID,
    val proposerPower: String,
    val recipientPower: String,
    val myCommitments: String, // JSONB
    val yourCommitments: String, // JSONB
    val status: String,
    val respondedAt: Instant?
)

data class ProposalRespondRequest(
    @field:NotBlank
    val response: String // ACCEPT, REJECT
)

// ================================================================
// READ RECEIPTS
// ================================================================

data class MarkReadRequest(
    val upToMessageId: UUID
)

// ================================================================
// WEBSOCKET EVENTS
// ================================================================

data class WebSocketEvent(
    val event: String,
    val seq: Long? = null,
    val gameId: UUID? = null,
    val timestamp: Instant = Instant.now(),
    val data: Any
)

data class NewMessageEvent(
    val conversationId: UUID,
    val message: MessageResponse,
    val senderPower: String
)

data class ReadReceiptEvent(
    val conversationId: UUID,
    val readByPower: String,
    val upToMessageId: UUID
)

// ================================================================
// EXTENSIONS
// ================================================================

fun Message.toResponse() = MessageResponse(
    id = id!!,
    conversationId = conversationId,
    senderPlayerId = senderPlayerId,
    senderPower = senderPower,
    type = type,
    content = content,
    replyToId = replyToId,
    gamePhase = gamePhase,
    isSystem = isSystem,
    sentAt = sentAt
)

fun Proposal.toResponse() = ProposalResponse(
    id = id!!,
    messageId = messageId,
    proposerPower = proposerPower,
    recipientPower = recipientPower,
    myCommitments = myCommitments,
    yourCommitments = yourCommitments,
    status = status,
    respondedAt = respondedAt
)
