CREATE TABLE conversation_participants (
    conversation_id         UUID            NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    power                   VARCHAR(20)     NOT NULL,
    player_id               UUID            NOT NULL REFERENCES players(id),
    is_muted                BOOLEAN         NOT NULL DEFAULT FALSE,
    is_pinned               BOOLEAN         NOT NULL DEFAULT FALSE,
    last_read_message_id    UUID,
    joined_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    PRIMARY KEY (conversation_id, power)
);

CREATE INDEX idx_conversation_participants_player ON conversation_participants (player_id);
