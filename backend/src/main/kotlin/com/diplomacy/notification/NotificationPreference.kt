package com.diplomacy.notification

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("notification_preferences")
data class NotificationPreference(
    @Id val id: UUID? = null,
    val playerId: UUID,
    val globalPrefs: String = "{}", // JSONB
    val perGamePrefs: String = "{}", // JSONB
    val updatedAt: Instant = Instant.now()
)
