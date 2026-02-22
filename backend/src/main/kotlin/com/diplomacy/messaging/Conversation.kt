package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("conversations")
data class Conversation(
    @Id val id: UUID? = null,
    @Column("game_id") val gameId: UUID,
    @Column("type") val type: String, // BILATERAL, GROUP, GLOBAL_PRESS
    @Column("name") val name: String? = null,
    @Column("created_at") val createdAt: Instant = Instant.now()
)
