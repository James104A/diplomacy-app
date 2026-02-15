package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("messages")
data class Message(
    @Id val id: UUID? = null,
    val conversationId: UUID,
    val senderPlayerId: UUID,
    val senderPower: String,
    val type: String, // TEXT, MAP_ANNOTATION, PROPOSAL, SYSTEM
    val content: String, // JSONB stored as String
    val replyToId: UUID? = null,
    val gamePhase: String,
    val isSystem: Boolean = false,
    val sentAt: Instant = Instant.now()
)
