package com.diplomacy.messaging

import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("conversation_participants")
data class ConversationParticipant(
    val conversationId: UUID,
    val power: String,
    val playerId: UUID,
    val isMuted: Boolean = false,
    val isPinned: Boolean = false,
    val lastReadMessageId: UUID? = null,
    val joinedAt: Instant = Instant.now()
)
