package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("proposals")
data class Proposal(
    @Id val id: UUID? = null,
    @Column("message_id") val messageId: UUID,
    @Column("proposer_power") val proposerPower: String,
    @Column("recipient_power") val recipientPower: String,
    @Column("my_commitments") val myCommitments: String, // JSONB
    @Column("your_commitments") val yourCommitments: String, // JSONB
    @Column("status") val status: String = "PENDING", // PENDING, ACCEPTED, REJECTED
    @Column("responded_at") val respondedAt: Instant? = null
)
