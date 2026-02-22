package com.diplomacy.messaging

import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("conversation_participants")
data class ConversationParticipant(
    @Column("conversation_id") val conversationId: UUID,
    @Column("power") val power: String,
    @Column("player_id") val playerId: UUID,
    @Column("is_muted") val isMuted: Boolean = false,
    @Column("is_pinned") val isPinned: Boolean = false,
    @Column("last_read_message_id") val lastReadMessageId: UUID? = null,
    @Column("joined_at") val joinedAt: Instant = Instant.now()
)
