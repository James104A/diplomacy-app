package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("messages")
data class Message(
    @Id val id: UUID? = null,
    @Column("conversation_id") val conversationId: UUID,
    @Column("sender_player_id") val senderPlayerId: UUID,
    @Column("sender_power") val senderPower: String,
    @Column("type") val type: String, // TEXT, MAP_ANNOTATION, PROPOSAL, SYSTEM
    @Column("content") val content: String, // JSONB stored as String
    @Column("reply_to_id") val replyToId: UUID? = null,
    @Column("game_phase") val gamePhase: String,
    @Column("is_system") val isSystem: Boolean = false,
    @Column("sent_at") val sentAt: Instant = Instant.now()
)
