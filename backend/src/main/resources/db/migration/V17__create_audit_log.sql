CREATE TABLE audit_log (
    id          BIGINT          PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    game_id     UUID            NOT NULL,
    player_id   UUID,
    action      VARCHAR(50)     NOT NULL,
    power       VARCHAR(20),
    details     JSONB,
    ip_hash     VARCHAR(64),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- No FK on game_id: audit entries must survive game deletion
-- No UPDATE/DELETE granted to application role (append-only)

CREATE INDEX idx_audit_log_game ON audit_log (game_id, created_at);
CREATE INDEX idx_audit_log_player ON audit_log (player_id, created_at);
CREATE INDEX idx_audit_log_action ON audit_log (action);
