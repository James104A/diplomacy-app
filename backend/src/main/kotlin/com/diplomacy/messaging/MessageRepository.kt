package com.diplomacy.messaging

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.util.UUID

interface MessageRepository : ReactiveCrudRepository<Message, UUID> {

    @Query("""
        SELECT * FROM messages
        WHERE conversation_id = :conversationId
        ORDER BY sent_at DESC
        LIMIT :limit OFFSET :offset
    """)
    fun findByConversationIdPaginated(conversationId: UUID, limit: Int, offset: Int): Flux<Message>

    @Query("""
        SELECT * FROM messages
        WHERE conversation_id = :conversationId AND sent_at < (SELECT sent_at FROM messages WHERE id = :cursor)
        ORDER BY sent_at DESC
        LIMIT :limit
    """)
    fun findByConversationIdBeforeCursor(conversationId: UUID, cursor: UUID, limit: Int): Flux<Message>

    @Query("""
        SELECT * FROM messages
        WHERE conversation_id = :conversationId
        ORDER BY sent_at DESC
        LIMIT 1
    """)
    fun findLastByConversationId(conversationId: UUID): Mono<Message>

    @Query("""
        SELECT COUNT(*) FROM messages
        WHERE conversation_id = :conversationId
        AND sent_at > COALESCE(
            (SELECT sent_at FROM messages WHERE id = :lastReadMessageId),
            '1970-01-01'::timestamptz
        )
    """)
    fun countUnreadMessages(conversationId: UUID, lastReadMessageId: UUID?): Mono<Long>
}
