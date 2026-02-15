package com.diplomacy.notification

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("player_devices")
data class PlayerDevice(
    @Id val id: UUID? = null,
    val playerId: UUID,
    val platform: String, // IOS, ANDROID
    val pushToken: String,
    val deviceId: String,
    val deviceModel: String? = null,
    val osVersion: String? = null,
    val appInstallId: String,
    val ipHash: String? = null,
    val timezone: String? = null,
    val isActive: Boolean = true,
    val createdAt: Instant = Instant.now(),
    val lastSeenAt: Instant = Instant.now()
)
