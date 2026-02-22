package com.diplomacy.notification

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("player_devices")
data class PlayerDevice(
    @Id val id: UUID? = null,
    @Column("player_id") val playerId: UUID,
    @Column("platform") val platform: String, // IOS, ANDROID
    @Column("push_token") val pushToken: String,
    @Column("device_id") val deviceId: String,
    @Column("device_model") val deviceModel: String? = null,
    @Column("os_version") val osVersion: String? = null,
    @Column("app_install_id") val appInstallId: String,
    @Column("ip_hash") val ipHash: String? = null,
    @Column("timezone") val timezone: String? = null,
    @Column("is_active") val isActive: Boolean = true,
    @Column("created_at") val createdAt: Instant = Instant.now(),
    @Column("last_seen_at") val lastSeenAt: Instant = Instant.now()
)
