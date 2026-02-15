package com.diplomacy.messaging

import com.diplomacy.game.GamePlayerRepository
import com.diplomacy.game.GameRepository
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

@Service
class MessagingService(
    private val conversationRepository: ConversationRepository,
    private val participantRepository: ConversationParticipantRepository,
    private val messageRepository: MessageRepository,
    private val proposalRepository: ProposalRepository,
    private val gameRepository: GameRepository,
    private val gamePlayerRepository: GamePlayerRepository,
    private val objectMapper: ObjectMapper
) {
    private val log = LoggerFactory.getLogger(MessagingService::class.java)

    companion object {
        private val POWERS = listOf("ENGLAND", "FRANCE", "GERMANY", "ITALY", "AUSTRIA", "RUSSIA", "TURKEY")
        private const val DEFAULT_PAGE_SIZE = 25
        private const val MAX_PAGE_SIZE = 100
    }

    // ================================================================
    // E5-S1: AUTO-CREATE CONVERSATIONS ON GAME START
    // ================================================================

    fun createConversationsForGame(gameId: UUID, players: List<Pair<String, UUID>>): Mono<Void> {
        log.info("Creating conversations for game $gameId")

        val conversations = mutableListOf<Conversation>()

        // Create 21 bilateral conversations (one per pair)
        for (i in players.indices) {
            for (j in i + 1 until players.size) {
                val (powerA, _) = players[i]
                val (powerB, _) = players[j]
                conversations.add(Conversation(
                    gameId = gameId,
                    type = "BILATERAL",
                    name = "$powerA-$powerB"
                ))
            }
        }

        // Create 1 global press conversation
        conversations.add(Conversation(
            gameId = gameId,
            type = "GLOBAL_PRESS",
            name = "Global Press"
        ))

        return Flux.fromIterable(conversations)
            .flatMap { conv ->
                conversationRepository.save(conv).flatMap { saved ->
                    val participants = when (conv.type) {
                        "BILATERAL" -> {
                            // Parse powers from name
                            val powers = conv.name!!.split("-")
                            players.filter { it.first in powers }
                        }
                        "GLOBAL_PRESS" -> players
                        else -> players
                    }

                    Flux.fromIterable(participants)
                        .flatMap { (power, playerId) ->
                            participantRepository.save(ConversationParticipant(
                                conversationId = saved.id!!,
                                power = power,
                                playerId = playerId
                            ))
                        }
                        .then()
                }
            }
            .then()
            .doOnSuccess { log.info("Created ${conversations.size} conversations for game $gameId") }
    }

    // ================================================================
    // E5-S2: SEND TEXT MESSAGE
    // ================================================================

    fun sendMessage(
        conversationId: UUID,
        playerId: UUID,
        request: SendMessageRequest
    ): Mono<MessageResponse> {
        return conversationRepository.findById(conversationId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Conversation not found")))
            .flatMap { conversation ->
                // Validate sender is a participant
                participantRepository.findByConversationIdAndPlayerId(conversationId, playerId)
                    .switchIfEmpty(Mono.error(IllegalStateException("Not a participant in this conversation")))
                    .flatMap { participant ->
                        // Check press rules
                        gameRepository.findById(conversation.gameId).flatMap { game ->
                            // Enforce press rules
                            if (conversation.type == "BILATERAL" && game.pressRules == "GUNBOAT") {
                                return@flatMap Mono.error<MessageResponse>(
                                    IllegalStateException("Bilateral messaging is not allowed in Gunboat games")
                                )
                            }
                            if (conversation.type == "BILATERAL" && game.pressRules == "PUBLIC_ONLY") {
                                return@flatMap Mono.error<MessageResponse>(
                                    IllegalStateException("Only public press is allowed in this game")
                                )
                            }

                            val phaseLabel = "${if (game.currentSeason == "SPRING") "S" else "F"}${game.currentYear}"

                            val message = Message(
                                conversationId = conversationId,
                                senderPlayerId = playerId,
                                senderPower = participant.power,
                                type = request.type,
                                content = request.content,
                                replyToId = request.replyTo,
                                gamePhase = phaseLabel
                            )

                            messageRepository.save(message).flatMap { saved ->
                                // If it's a proposal, create the proposal record
                                if (request.type == "PROPOSAL") {
                                    createProposalFromMessage(saved, conversation, participant.power)
                                        .thenReturn(saved.toResponse())
                                } else {
                                    Mono.just(saved.toResponse())
                                }
                            }.flatMap { response ->
                                // Update unread counts for other participants
                                updateUnreadCounts(conversationId, playerId, conversation.gameId)
                                    .thenReturn(response)
                            }
                        }
                    }
            }
    }

    private fun createProposalFromMessage(
        message: Message,
        conversation: Conversation,
        senderPower: String
    ): Mono<Proposal> {
        val contentNode = objectMapper.readTree(message.content)
        val myCommitments = contentNode.get("myCommitments")?.toString() ?: "[]"
        val yourCommitments = contentNode.get("yourCommitments")?.toString() ?: "[]"

        // For bilateral conversations, the recipient is the other participant
        return participantRepository.findByConversationId(conversation.id!!)
            .filter { it.power != senderPower }
            .next()
            .flatMap { recipient ->
                proposalRepository.save(Proposal(
                    messageId = message.id!!,
                    proposerPower = senderPower,
                    recipientPower = recipient.power,
                    myCommitments = myCommitments,
                    yourCommitments = yourCommitments
                ))
            }
    }

    private fun updateUnreadCounts(conversationId: UUID, senderPlayerId: UUID, gameId: UUID): Mono<Void> {
        // Increment unread_message_count on game_players for all participants except sender
        return participantRepository.findByConversationId(conversationId)
            .filter { it.playerId != senderPlayerId }
            .flatMap { participant ->
                gamePlayerRepository.findByGameIdAndPlayerId(gameId, participant.playerId)
                    .flatMap { gp ->
                        gamePlayerRepository.save(gp.copy(
                            unreadMessageCount = gp.unreadMessageCount + 1
                        ))
                    }
            }
            .then()
    }

    // ================================================================
    // E5-S3: MESSAGE PAGINATION
    // ================================================================

    fun getMessages(
        conversationId: UUID,
        playerId: UUID,
        cursor: UUID?,
        limit: Int?
    ): Mono<MessagePageResponse> {
        val pageSize = (limit ?: DEFAULT_PAGE_SIZE).coerceIn(1, MAX_PAGE_SIZE)

        return participantRepository.findByConversationIdAndPlayerId(conversationId, playerId)
            .switchIfEmpty(Mono.error(IllegalStateException("Not a participant in this conversation")))
            .flatMap {
                val messageFlux = if (cursor != null) {
                    messageRepository.findByConversationIdBeforeCursor(conversationId, cursor, pageSize + 1)
                } else {
                    messageRepository.findByConversationIdPaginated(conversationId, pageSize + 1, 0)
                }

                messageFlux.collectList().map { messages ->
                    val hasMore = messages.size > pageSize
                    val page = if (hasMore) messages.take(pageSize) else messages
                    val nextCursor = if (hasMore) page.lastOrNull()?.id else null

                    MessagePageResponse(
                        messages = page.map { it.toResponse() },
                        nextCursor = nextCursor,
                        hasMore = hasMore
                    )
                }
            }
    }

    // ================================================================
    // E5-S4: CONVERSATION LIST
    // ================================================================

    fun getConversations(gameId: UUID, playerId: UUID): Mono<ConversationListResponse> {
        return conversationRepository.findByGameId(gameId).collectList().flatMap { conversations ->
            // Get participant data for the requesting player
            participantRepository.findByPlayerIdAndGameId(playerId, gameId)
                .collectList()
                .flatMap { myParticipations ->
                    val myConvIds = myParticipations.associate { it.conversationId to it }

                    // Only include conversations the player participates in
                    val relevantConvs = conversations.filter { it.id in myConvIds }

                    Flux.fromIterable(relevantConvs)
                        .flatMap { conv ->
                            val myParticipation = myConvIds[conv.id!!]!!

                            Mono.zip(
                                participantRepository.findByConversationId(conv.id)
                                    .map { it.power }
                                    .collectList(),
                                messageRepository.findLastByConversationId(conv.id)
                                    .map { msg ->
                                        val isRead = myParticipation.lastReadMessageId != null &&
                                            myParticipation.lastReadMessageId == msg.id
                                        val preview = extractPreview(msg)
                                        LastMessagePreview(
                                            senderPower = msg.senderPower,
                                            preview = preview,
                                            sentAt = msg.sentAt,
                                            read = isRead
                                        )
                                    }
                                    .defaultIfEmpty(LastMessagePreview("", "", Instant.EPOCH, true)),
                                messageRepository.countUnreadMessages(conv.id, myParticipation.lastReadMessageId)
                            ).map { tuple ->
                                val participants = tuple.t1
                                val lastMessage = if (tuple.t2.senderPower.isEmpty()) null else tuple.t2
                                val unreadCount = tuple.t3

                                ConversationSummary(
                                    id = conv.id,
                                    type = conv.type,
                                    name = conv.name,
                                    participants = participants,
                                    lastMessage = lastMessage,
                                    unreadCount = unreadCount,
                                    isMuted = myParticipation.isMuted,
                                    isPinned = myParticipation.isPinned
                                )
                            }
                        }
                        .collectList()
                        .map { summaries ->
                            // Sort: pinned first, then unread first, then by most recent message
                            val sorted = summaries.sortedWith(
                                compareByDescending<ConversationSummary> { it.isPinned }
                                    .thenByDescending { it.unreadCount > 0 }
                                    .thenByDescending { it.lastMessage?.sentAt ?: Instant.EPOCH }
                            )
                            ConversationListResponse(conversations = sorted)
                        }
                }
        }
    }

    private fun extractPreview(message: Message): String {
        return when (message.type) {
            "TEXT" -> {
                val node = objectMapper.readTree(message.content)
                val text = node.get("text")?.asText() ?: message.content
                if (text.length > 100) text.take(100) + "..." else text
            }
            "MAP_ANNOTATION" -> "[Map annotation]"
            "PROPOSAL" -> "[Proposal]"
            "SYSTEM" -> {
                val node = objectMapper.readTree(message.content)
                node.get("text")?.asText() ?: "[System message]"
            }
            else -> message.content
        }
    }

    // ================================================================
    // E5-S5: REAL-TIME (helper for WebSocket broadcast)
    // ================================================================

    fun getConversationParticipants(conversationId: UUID): Flux<ConversationParticipant> {
        return participantRepository.findByConversationId(conversationId)
    }

    // ================================================================
    // E5-S6: READ RECEIPTS
    // ================================================================

    fun markRead(
        conversationId: UUID,
        playerId: UUID,
        upToMessageId: UUID
    ): Mono<Void> {
        return participantRepository.findByConversationIdAndPlayerId(conversationId, playerId)
            .switchIfEmpty(Mono.error(IllegalStateException("Not a participant")))
            .flatMap { participant ->
                // Update last_read_message_id
                participantRepository.save(participant.copy(lastReadMessageId = upToMessageId))
                    .flatMap { _ ->
                        // Recalculate unread count for this conversation
                        messageRepository.countUnreadMessages(conversationId, upToMessageId)
                            .flatMap { remaining ->
                                // Update the denormalized count on game_players
                                // We need to recalculate total unread across all conversations
                                recalculateUnreadCount(playerId, conversationId)
                            }
                    }
            }
    }

    private fun recalculateUnreadCount(playerId: UUID, conversationId: UUID): Mono<Void> {
        // Find the game for this conversation
        return conversationRepository.findById(conversationId).flatMap { conversation ->
            // Sum unread across all conversations in this game for this player
            participantRepository.findByPlayerIdAndGameId(playerId, conversation.gameId)
                .flatMap { participation ->
                    messageRepository.countUnreadMessages(
                        participation.conversationId,
                        participation.lastReadMessageId
                    )
                }
                .reduce(0L) { acc, count -> acc + count }
                .flatMap { totalUnread ->
                    gamePlayerRepository.findByGameIdAndPlayerId(conversation.gameId, playerId)
                        .flatMap { gp ->
                            gamePlayerRepository.save(gp.copy(
                                unreadMessageCount = totalUnread.toInt()
                            ))
                        }
                }
                .then()
        }
    }

    // ================================================================
    // PROPOSALS
    // ================================================================

    fun respondToProposal(proposalId: UUID, playerId: UUID, response: String): Mono<ProposalResponse> {
        return proposalRepository.findById(proposalId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Proposal not found")))
            .flatMap { proposal ->
                if (proposal.status != "PENDING") {
                    return@flatMap Mono.error<ProposalResponse>(
                        IllegalStateException("Proposal already ${proposal.status.lowercase()}")
                    )
                }

                // Verify the responder is the recipient
                messageRepository.findById(proposal.messageId).flatMap { message ->
                    participantRepository.findByConversationIdAndPlayerId(message.conversationId, playerId)
                        .switchIfEmpty(Mono.error(IllegalStateException("Not authorized")))
                        .flatMap { participant ->
                            if (participant.power != proposal.recipientPower) {
                                return@flatMap Mono.error<ProposalResponse>(
                                    IllegalStateException("Only the recipient can respond")
                                )
                            }

                            proposalRepository.save(proposal.copy(
                                status = response.uppercase(),
                                respondedAt = Instant.now()
                            )).map { it.toResponse() }
                        }
                }
            }
    }

    // ================================================================
    // GROUP CHAT
    // ================================================================

    fun createGroupChat(
        gameId: UUID,
        playerId: UUID,
        request: CreateGroupChatRequest
    ): Mono<ConversationSummary> {
        return gameRepository.findById(gameId)
            .switchIfEmpty(Mono.error(IllegalArgumentException("Game not found")))
            .flatMap { game ->
                if (game.pressRules == "GUNBOAT") {
                    return@flatMap Mono.error<ConversationSummary>(
                        IllegalStateException("Group chats not allowed in Gunboat games")
                    )
                }

                // Verify requester is a player in this game
                gamePlayerRepository.findByGameIdAndPlayerId(gameId, playerId)
                    .switchIfEmpty(Mono.error(IllegalStateException("Not a participant")))
                    .flatMap { requesterPlayer ->
                        val conversation = Conversation(
                            gameId = gameId,
                            type = "GROUP",
                            name = request.name
                        )

                        conversationRepository.save(conversation).flatMap { saved ->
                            // Add all specified powers as participants
                            gamePlayerRepository.findByGameId(gameId)
                                .filter { it.power in request.participants }
                                .flatMap { gp ->
                                    participantRepository.save(ConversationParticipant(
                                        conversationId = saved.id!!,
                                        power = gp.power,
                                        playerId = gp.playerId
                                    ))
                                }
                                .collectList()
                                .map { participants ->
                                    ConversationSummary(
                                        id = saved.id!!,
                                        type = "GROUP",
                                        name = request.name,
                                        participants = participants.map { it.power },
                                        lastMessage = null,
                                        unreadCount = 0,
                                        isMuted = false,
                                        isPinned = false
                                    )
                                }
                        }
                    }
            }
    }
}
