package com.diplomacy.notification

import com.diplomacy.game.GamePlayerRepository
import com.diplomacy.messaging.GameWebSocketHandler
import com.diplomacy.messaging.WebSocketEvent
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

/**
 * E6: Notification Service.
 *
 * Handles device registration, notification preferences, push dispatch,
 * and deep link generation. Checks WebSocket connectivity before sending
 * push notifications (skip push if player is connected via WebSocket).
 */
@Service
class NotificationService(
    private val deviceRepository: PlayerDeviceRepository,
    private val prefsRepository: NotificationPreferenceRepository,
    private val gamePlayerRepository: GamePlayerRepository,
    private val webSocketHandler: GameWebSocketHandler,
    private val objectMapper: ObjectMapper
) {
    private val log = LoggerFactory.getLogger(NotificationService::class.java)

    // ================================================================
    // E6-S1: DEVICE REGISTRATION
    // ================================================================

    fun registerDevice(playerId: UUID, request: RegisterDeviceRequest): Mono<DeviceResponse> {
        return deviceRepository.findByPlayerIdAndDeviceId(playerId, request.deviceId)
            .flatMap { existing ->
                // Update existing device token
                deviceRepository.save(existing.copy(
                    pushToken = request.token,
                    platform = request.platform,
                    deviceModel = request.deviceModel ?: existing.deviceModel,
                    osVersion = request.osVersion ?: existing.osVersion,
                    timezone = request.timezone ?: existing.timezone,
                    isActive = true,
                    lastSeenAt = Instant.now()
                ))
            }
            .switchIfEmpty(
                // Register new device
                deviceRepository.save(PlayerDevice(
                    playerId = playerId,
                    platform = request.platform,
                    pushToken = request.token,
                    deviceId = request.deviceId,
                    deviceModel = request.deviceModel,
                    osVersion = request.osVersion,
                    appInstallId = request.appInstallId ?: UUID.randomUUID().toString(),
                    timezone = request.timezone
                ))
            )
            .map { it.toResponse() }
    }

    fun deactivateDevice(playerId: UUID, deviceId: String): Mono<Void> {
        return deviceRepository.deactivateDevice(playerId, deviceId)
    }

    fun getActiveDevices(playerId: UUID): Flux<PlayerDevice> {
        return deviceRepository.findByPlayerIdAndIsActive(playerId, true)
    }

    // ================================================================
    // E6-S2: NOTIFICATION DISPATCH
    // ================================================================

    /**
     * Dispatch notifications for a game event to all players in the game.
     * Checks WebSocket connectivity: skip push if player is connected.
     */
    fun notifyGamePlayers(gameId: UUID, event: GameEvent, excludePlayerId: UUID? = null): Mono<Void> {
        return gamePlayerRepository.findByGameId(gameId)
            .filter { !it.isEliminated }
            .filter { excludePlayerId == null || it.playerId != excludePlayerId }
            .flatMap { gamePlayer ->
                sendNotificationToPlayer(gamePlayer.playerId, event)
            }
            .then()
    }

    /**
     * Send a notification to a specific player.
     * Pipeline: check prefs → check WebSocket → format → dispatch push
     */
    fun sendNotificationToPlayer(playerId: UUID, event: GameEvent): Mono<Void> {
        // Step 1: Check if player is connected via WebSocket
        if (webSocketHandler.isPlayerConnected(playerId)) {
            log.debug("Player $playerId connected via WebSocket, skipping push for ${event.type}")
            // Still send via WebSocket
            val wsEvent = WebSocketEvent(
                event = event.type.name.lowercase(),
                gameId = event.gameId,
                data = event.data
            )
            webSocketHandler.sendToPlayer(playerId, wsEvent)
            return Mono.empty()
        }

        // Step 2: Check notification preferences
        return prefsRepository.findByPlayerId(playerId)
            .defaultIfEmpty(NotificationPreference(playerId = playerId))
            .flatMap { prefs ->
                if (isNotificationMuted(prefs, event)) {
                    log.debug("Notification muted for player $playerId, game ${event.gameId}, type ${event.type}")
                    return@flatMap Mono.empty<Void>()
                }

                // Step 3: Format push notification
                val push = formatPushNotification(playerId, event)

                // Step 4: Dispatch to active devices
                deviceRepository.findByPlayerIdAndIsActive(playerId, true)
                    .flatMap { device ->
                        dispatchPush(device, push)
                    }
                    .then()
            }
    }

    /**
     * Send a notification for a new message to a specific player.
     */
    fun notifyNewMessage(
        playerId: UUID,
        gameId: UUID,
        gameName: String,
        senderPower: String,
        conversationId: UUID,
        preview: String
    ): Mono<Void> {
        val event = GameEvent(
            type = GameEventType.MESSAGE_SENT,
            gameId = gameId,
            gameName = gameName,
            data = mapOf(
                "senderPower" to senderPower,
                "conversationId" to conversationId.toString(),
                "preview" to preview
            )
        )
        return sendNotificationToPlayer(playerId, event)
    }

    private fun isNotificationMuted(prefs: NotificationPreference, event: GameEvent): Boolean {
        val globalPrefs = parseGlobalPrefs(prefs.globalPrefs)
        val perGamePrefs = parsePerGamePrefs(prefs.perGamePrefs)
        val gamePrefs = perGamePrefs[event.gameId.toString()]

        // Check per-game mute
        if (gamePrefs?.muted == true) return true

        // Check per-game overrides first, then global
        val effectivePrefs = gamePrefs?.overrides ?: globalPrefs

        return when (event.type) {
            GameEventType.MESSAGE_SENT -> !effectivePrefs.newMessage
            GameEventType.PHASE_RESOLVED -> effectivePrefs.phaseResolved == "OFF"
            GameEventType.DEADLINE_APPROACHING -> effectivePrefs.deadlineReminder == "OFF"
            GameEventType.ORDERS_NOT_SUBMITTED -> effectivePrefs.ordersReminder == "OFF"
            // These cannot be disabled
            GameEventType.GAME_STARTED,
            GameEventType.GAME_ENDED,
            GameEventType.PLAYER_ELIMINATED,
            GameEventType.DRAW_PROPOSED -> false
        }
    }

    private fun parseGlobalPrefs(json: String): GlobalNotificationPrefs {
        return try {
            objectMapper.readValue(json, GlobalNotificationPrefs::class.java)
        } catch (e: Exception) {
            GlobalNotificationPrefs()
        }
    }

    private fun parsePerGamePrefs(json: String): Map<String, GameNotificationPrefs> {
        return try {
            objectMapper.readValue(
                json,
                objectMapper.typeFactory.constructMapType(
                    Map::class.java,
                    String::class.java,
                    GameNotificationPrefs::class.java
                )
            )
        } catch (e: Exception) {
            emptyMap()
        }
    }

    // ================================================================
    // E6-S4: DEEP LINK GENERATION
    // ================================================================

    private fun formatPushNotification(playerId: UUID, event: GameEvent): PushNotification {
        return when (event.type) {
            GameEventType.PHASE_RESOLVED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "New turn: ${event.data["phaseLabel"] ?: "phase resolved"}",
                deepLink = "diplomacy://game/${event.gameId}/map",
                category = NotificationCategory.PHASE_RESOLVED,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.MESSAGE_SENT -> PushNotification(
                playerId = playerId,
                title = "${event.data["senderPower"] ?: "Unknown"} — ${event.gameName}",
                body = event.data["preview"] ?: "New message",
                deepLink = "diplomacy://game/${event.gameId}/messages/${event.data["conversationId"]}",
                category = NotificationCategory.NEW_MESSAGE,
                data = mapOf(
                    "gameId" to event.gameId.toString(),
                    "conversationId" to (event.data["conversationId"] ?: "")
                )
            )
            GameEventType.DEADLINE_APPROACHING -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "Deadline approaching — submit your orders",
                deepLink = "diplomacy://game/${event.gameId}/orders",
                category = NotificationCategory.DEADLINE_APPROACHING,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.ORDERS_NOT_SUBMITTED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "You haven't submitted orders yet",
                deepLink = "diplomacy://game/${event.gameId}/orders",
                category = NotificationCategory.ORDERS_REMINDER,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.GAME_STARTED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "Game has started! You are ${event.data["power"] ?: "a power"}",
                deepLink = "diplomacy://game/${event.gameId}/map",
                category = NotificationCategory.GAME_STARTED,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.GAME_ENDED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = event.data["result"] ?: "Game has ended",
                deepLink = "diplomacy://game/${event.gameId}/map",
                category = NotificationCategory.GAME_ENDED,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.PLAYER_ELIMINATED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "You have been eliminated",
                deepLink = "diplomacy://game/${event.gameId}/map",
                category = NotificationCategory.PLAYER_ELIMINATED,
                data = mapOf("gameId" to event.gameId.toString())
            )
            GameEventType.DRAW_PROPOSED -> PushNotification(
                playerId = playerId,
                title = event.gameName,
                body = "A draw has been proposed — vote now",
                deepLink = "diplomacy://game/${event.gameId}/map",
                category = NotificationCategory.DRAW_PROPOSED,
                data = mapOf("gameId" to event.gameId.toString())
            )
        }
    }

    /**
     * Dispatch a push notification to a device.
     * In production, this calls APNs (iOS) or FCM (Android).
     * Currently logs the push for development/testing.
     */
    private fun dispatchPush(device: PlayerDevice, push: PushNotification): Mono<Void> {
        return Mono.fromRunnable {
            log.info(
                "PUSH [{}] to device {} ({}): {} — {}{}",
                push.category,
                device.deviceId,
                device.platform,
                push.title,
                push.body,
                push.deepLink?.let { " → $it" } ?: ""
            )
            // TODO: Integrate with APNs/FCM in production
            // For iOS: Use APNs HTTP/2 client
            // For Android: Use FCM HTTP v1 API
        }
    }

    // ================================================================
    // E6-S3: NOTIFICATION PREFERENCES
    // ================================================================

    fun getPreferences(playerId: UUID): Mono<NotificationPreferencesDto> {
        return prefsRepository.findByPlayerId(playerId)
            .defaultIfEmpty(NotificationPreference(playerId = playerId))
            .map { prefs ->
                NotificationPreferencesDto(
                    global = parseGlobalPrefs(prefs.globalPrefs),
                    perGame = parsePerGamePrefs(prefs.perGamePrefs)
                )
            }
    }

    fun updatePreferences(playerId: UUID, dto: NotificationPreferencesDto): Mono<NotificationPreferencesDto> {
        return prefsRepository.findByPlayerId(playerId)
            .defaultIfEmpty(NotificationPreference(playerId = playerId))
            .flatMap { existing ->
                val updated = existing.copy(
                    globalPrefs = objectMapper.writeValueAsString(dto.global),
                    perGamePrefs = objectMapper.writeValueAsString(dto.perGame),
                    updatedAt = Instant.now()
                )
                prefsRepository.save(updated)
            }
            .map { saved ->
                NotificationPreferencesDto(
                    global = parseGlobalPrefs(saved.globalPrefs),
                    perGame = parsePerGamePrefs(saved.perGamePrefs)
                )
            }
    }

    // ================================================================
    // DEADLINE REMINDER SCHEDULING
    // ================================================================

    /**
     * Check if deadline reminders should fire for a game.
     * Called by DeadlineScheduler on its 30s polling interval.
     */
    fun checkDeadlineReminders(gameId: UUID, gameName: String, deadline: Instant): Mono<Void> {
        val now = Instant.now()

        return gamePlayerRepository.findByGameId(gameId)
            .filter { !it.isEliminated }
            .flatMap { gamePlayer ->
                prefsRepository.findByPlayerId(gamePlayer.playerId)
                    .defaultIfEmpty(NotificationPreference(playerId = gamePlayer.playerId))
                    .flatMap { prefs ->
                        val globalPrefs = parseGlobalPrefs(prefs.globalPrefs)
                        val perGamePrefs = parsePerGamePrefs(prefs.perGamePrefs)
                        val gamePrefs = perGamePrefs[gameId.toString()]

                        if (gamePrefs?.muted == true) return@flatMap Mono.empty<Void>()

                        val effectivePrefs = gamePrefs?.overrides ?: globalPrefs

                        // Check deadline reminder
                        val reminderDuration = parseDuration(effectivePrefs.deadlineReminder)
                        if (reminderDuration != null) {
                            val reminderTime = deadline.minus(reminderDuration)
                            if (now.isAfter(reminderTime) && now.isBefore(deadline)) {
                                val event = GameEvent(
                                    type = GameEventType.DEADLINE_APPROACHING,
                                    gameId = gameId,
                                    gameName = gameName
                                )
                                return@flatMap sendNotificationToPlayer(gamePlayer.playerId, event)
                            }
                        }

                        // Check orders reminder for players who haven't submitted
                        if (!gamePlayer.ordersSubmitted) {
                            val ordersReminderDuration = parseDuration(effectivePrefs.ordersReminder)
                            if (ordersReminderDuration != null) {
                                val reminderTime = deadline.minus(ordersReminderDuration)
                                if (now.isAfter(reminderTime) && now.isBefore(deadline)) {
                                    val event = GameEvent(
                                        type = GameEventType.ORDERS_NOT_SUBMITTED,
                                        gameId = gameId,
                                        gameName = gameName
                                    )
                                    return@flatMap sendNotificationToPlayer(gamePlayer.playerId, event)
                                }
                            }
                        }

                        Mono.empty()
                    }
            }
            .then()
    }

    private fun parseDuration(value: String): java.time.Duration? {
        if (value == "OFF") return null
        return try {
            java.time.Duration.parse(value)
        } catch (e: Exception) {
            null
        }
    }
}
