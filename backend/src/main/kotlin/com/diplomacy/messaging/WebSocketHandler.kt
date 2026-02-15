package com.diplomacy.messaging

import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.web.reactive.socket.WebSocketHandler
import org.springframework.web.reactive.socket.WebSocketSession
import reactor.core.publisher.Mono
import reactor.core.publisher.Sinks
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * E5-S5: WebSocket handler for real-time message delivery.
 *
 * Manages player connections and broadcasts events to connected clients.
 * In production, Redis Pub/Sub would fan out across multiple server instances.
 */
@Component
class GameWebSocketHandler(
    private val objectMapper: ObjectMapper
) : WebSocketHandler {

    private val log = LoggerFactory.getLogger(GameWebSocketHandler::class.java)

    // Map of playerId -> sink for broadcasting events
    private val playerSinks = ConcurrentHashMap<UUID, Sinks.Many<String>>()

    // Map of playerId -> session for connection management
    private val playerSessions = ConcurrentHashMap<UUID, WebSocketSession>()

    override fun handle(session: WebSocketSession): Mono<Void> {
        // Extract player ID from query params (JWT already validated by filter)
        val playerId = extractPlayerId(session)
            ?: return session.close()

        log.info("WebSocket connected: player $playerId")

        val sink = Sinks.many().multicast().onBackpressureBuffer<String>()
        playerSinks[playerId] = sink
        playerSessions[playerId] = session

        // Send outgoing messages from sink to client
        val output = session.send(
            sink.asFlux().map { session.textMessage(it) }
        )

        // Handle incoming messages (ping/pong, etc.)
        val input = session.receive()
            .doOnNext { message ->
                val payload = message.payloadAsText
                if (payload == "ping") {
                    sink.tryEmitNext("pong")
                }
            }
            .doFinally {
                log.info("WebSocket disconnected: player $playerId")
                playerSinks.remove(playerId)
                playerSessions.remove(playerId)
            }
            .then()

        return Mono.zip(input, output).then()
    }

    /**
     * Broadcast a new message event to all conversation participants.
     */
    fun broadcastNewMessage(participantPlayerIds: List<UUID>, event: WebSocketEvent) {
        val json = objectMapper.writeValueAsString(event)
        participantPlayerIds.forEach { playerId ->
            playerSinks[playerId]?.tryEmitNext(json)
        }
    }

    /**
     * Broadcast a read receipt event.
     */
    fun broadcastReadReceipt(participantPlayerIds: List<UUID>, event: WebSocketEvent) {
        val json = objectMapper.writeValueAsString(event)
        participantPlayerIds.forEach { playerId ->
            playerSinks[playerId]?.tryEmitNext(json)
        }
    }

    /**
     * Send an event to a specific player.
     */
    fun sendToPlayer(playerId: UUID, event: WebSocketEvent) {
        val json = objectMapper.writeValueAsString(event)
        playerSinks[playerId]?.tryEmitNext(json)
    }

    fun isPlayerConnected(playerId: UUID): Boolean = playerSinks.containsKey(playerId)

    fun connectedPlayerCount(): Int = playerSinks.size

    private fun extractPlayerId(session: WebSocketSession): UUID? {
        return try {
            val query = session.handshakeInfo.uri.query ?: return null
            val params = query.split("&").associate {
                val parts = it.split("=", limit = 2)
                parts[0] to (parts.getOrNull(1) ?: "")
            }
            // The playerId is set by the JWT auth filter on the handshake
            params["playerId"]?.let { UUID.fromString(it) }
        } catch (e: Exception) {
            log.error("Failed to extract player ID from WebSocket handshake", e)
            null
        }
    }
}
