package com.diplomacy.notification

import io.r2dbc.postgresql.codec.Json
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("notification_preferences")
data class NotificationPreference(
    @Id val id: UUID? = null,
    @Column("player_id") val playerId: UUID,
    @Column("global_prefs") val globalPrefs: Json = Json.of("{}"),
    @Column("per_game_prefs") val perGamePrefs: Json = Json.of("{}"),
    @Column("updated_at") val updatedAt: Instant = Instant.now()
)
