CREATE TABLE conversations (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id     UUID            NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    type        VARCHAR(20)     NOT NULL CHECK (type IN ('BILATERAL', 'GROUP', 'GLOBAL_PRESS')),
    name        VARCHAR(100),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_conversations_game ON conversations (game_id);
