package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("conversations")
data class Conversation(
    @Id val id: UUID? = null,
    val gameId: UUID,
    val type: String, // BILATERAL, GROUP, GLOBAL_PRESS
    val name: String? = null,
    val createdAt: Instant = Instant.now()
)
