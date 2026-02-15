package com.diplomacy.notification

import jakarta.validation.constraints.NotBlank
import java.time.Instant
import java.util.UUID

// ================================================================
// DEVICE REGISTRATION (E6-S1)
// ================================================================

data class RegisterDeviceRequest(
    @field:NotBlank
    val platform: String, // IOS, ANDROID
    @field:NotBlank
    val token: String,
    @field:NotBlank
    val deviceId: String,
    val deviceModel: String? = null,
    val osVersion: String? = null,
    val appInstallId: String? = null,
    val timezone: String? = null
)

data class DeviceResponse(
    val id: UUID,
    val platform: String,
    val deviceId: String,
    val isActive: Boolean,
    val createdAt: Instant
)

// ================================================================
// NOTIFICATION PREFERENCES (E6-S3)
// ================================================================

data class NotificationPreferencesDto(
    val global: GlobalNotificationPrefs,
    val perGame: Map<String, GameNotificationPrefs>
)

data class GlobalNotificationPrefs(
    val newMessage: Boolean = true,
    val phaseResolved: String = "IMMEDIATE", // IMMEDIATE, DAILY_DIGEST, OFF
    val deadlineReminder: String = "PT2H", // ISO 8601 duration or OFF
    val ordersReminder: String = "PT4H" // ISO 8601 duration or OFF
)

data class GameNotificationPrefs(
    val muted: Boolean = false,
    val overrides: GlobalNotificationPrefs? = null
)

// ================================================================
// PUSH NOTIFICATION PAYLOADS (E6-S2, E6-S4)
// ================================================================

data class PushNotification(
    val playerId: UUID,
    val title: String,
    val body: String,
    val deepLink: String? = null,
    val data: Map<String, String> = emptyMap(),
    val category: NotificationCategory
)

enum class NotificationCategory {
    NEW_MESSAGE,
    PHASE_RESOLVED,
    DEADLINE_APPROACHING,
    ORDERS_REMINDER,
    GAME_STARTED,
    GAME_ENDED,
    PLAYER_ELIMINATED,
    DRAW_PROPOSED
}

// ================================================================
// GAME EVENTS (internal, triggering notifications)
// ================================================================

data class GameEvent(
    val type: GameEventType,
    val gameId: UUID,
    val gameName: String,
    val data: Map<String, String> = emptyMap()
)

enum class GameEventType {
    PHASE_RESOLVED,
    MESSAGE_SENT,
    DEADLINE_APPROACHING,
    ORDERS_NOT_SUBMITTED,
    GAME_STARTED,
    GAME_ENDED,
    PLAYER_ELIMINATED,
    DRAW_PROPOSED
}

// ================================================================
// EXTENSIONS
// ================================================================

fun PlayerDevice.toResponse() = DeviceResponse(
    id = id!!,
    platform = platform,
    deviceId = deviceId,
    isActive = isActive,
    createdAt = createdAt
)
