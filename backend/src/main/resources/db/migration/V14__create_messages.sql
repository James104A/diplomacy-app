CREATE TABLE messages (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id     UUID            NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_player_id    UUID            NOT NULL REFERENCES players(id),
    sender_power        VARCHAR(20)     NOT NULL,
    type                VARCHAR(20)     NOT NULL CHECK (type IN ('TEXT', 'MAP_ANNOTATION', 'PROPOSAL', 'SYSTEM')),
    content             JSONB           NOT NULL,
    reply_to_id         UUID            REFERENCES messages(id),
    game_phase          VARCHAR(30)     NOT NULL,
    is_system           BOOLEAN         NOT NULL DEFAULT FALSE,
    sent_at             TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Add FK from conversation_participants now that messages table exists
ALTER TABLE conversation_participants
    ADD CONSTRAINT fk_last_read_message
    FOREIGN KEY (last_read_message_id) REFERENCES messages(id);

CREATE INDEX idx_messages_conversation ON messages (conversation_id, sent_at DESC);
CREATE INDEX idx_messages_content ON messages USING GIN (content);
CREATE INDEX idx_messages_phase ON messages (game_phase);
