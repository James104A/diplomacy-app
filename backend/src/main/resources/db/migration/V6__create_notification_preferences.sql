CREATE TABLE notification_preferences (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id       UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    global_prefs    JSONB           NOT NULL DEFAULT '{}',
    per_game_prefs  JSONB           NOT NULL DEFAULT '{}',
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_notification_prefs_player UNIQUE (player_id)
);
