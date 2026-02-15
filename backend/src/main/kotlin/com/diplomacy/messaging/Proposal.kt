package com.diplomacy.messaging

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("proposals")
data class Proposal(
    @Id val id: UUID? = null,
    val messageId: UUID,
    val proposerPower: String,
    val recipientPower: String,
    val myCommitments: String, // JSONB
    val yourCommitments: String, // JSONB
    val status: String = "PENDING", // PENDING, ACCEPTED, REJECTED
    val respondedAt: Instant? = null
)
