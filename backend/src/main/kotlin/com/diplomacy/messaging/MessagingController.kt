package com.diplomacy.messaging

import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.util.UUID

@RestController
class MessagingController(private val messagingService: MessagingService) {

    // E5-S4: List conversations for a game
    @GetMapping("/v1/games/{gameId}/conversations")
    fun getConversations(
        @PathVariable gameId: UUID,
        @AuthenticationPrincipal playerId: UUID
    ): Mono<ConversationListResponse> {
        return messagingService.getConversations(gameId, playerId)
    }

    // E5-S2: Send a message
    @PostMapping("/v1/conversations/{conversationId}/messages")
    @ResponseStatus(HttpStatus.CREATED)
    fun sendMessage(
        @PathVariable conversationId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: SendMessageRequest
    ): Mono<MessageResponse> {
        return messagingService.sendMessage(conversationId, playerId, request)
    }

    // E5-S3: Get paginated messages
    @GetMapping("/v1/conversations/{conversationId}/messages")
    fun getMessages(
        @PathVariable conversationId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @RequestParam(required = false) cursor: UUID?,
        @RequestParam(required = false) limit: Int?
    ): Mono<MessagePageResponse> {
        return messagingService.getMessages(conversationId, playerId, cursor, limit)
    }

    // E5-S6: Mark messages as read
    @PostMapping("/v1/conversations/{conversationId}/read")
    fun markRead(
        @PathVariable conversationId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: MarkReadRequest
    ): Mono<Void> {
        return messagingService.markRead(conversationId, playerId, request.upToMessageId)
    }

    // Respond to a proposal
    @PutMapping("/v1/proposals/{proposalId}/respond")
    fun respondToProposal(
        @PathVariable proposalId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: ProposalRespondRequest
    ): Mono<ProposalResponse> {
        return messagingService.respondToProposal(proposalId, playerId, request.response)
    }

    // Create a group chat
    @PostMapping("/v1/games/{gameId}/conversations/group")
    @ResponseStatus(HttpStatus.CREATED)
    fun createGroupChat(
        @PathVariable gameId: UUID,
        @AuthenticationPrincipal playerId: UUID,
        @Valid @RequestBody request: CreateGroupChatRequest
    ): Mono<ConversationSummary> {
        return messagingService.createGroupChat(gameId, playerId, request)
    }
}
