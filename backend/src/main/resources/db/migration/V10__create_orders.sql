CREATE TABLE orders (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id             UUID            NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    player_id           UUID            NOT NULL REFERENCES players(id),
    power               VARCHAR(20)     NOT NULL,
    phase               VARCHAR(20)     NOT NULL,
    season              VARCHAR(10)     NOT NULL,
    year                INTEGER         NOT NULL,
    orders              JSONB           NOT NULL,
    is_default          BOOLEAN         NOT NULL DEFAULT FALSE,
    validation_results  JSONB,
    submitted_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_adjudication ON orders (game_id, season, year, phase);
CREATE UNIQUE INDEX idx_orders_player_phase ON orders (game_id, player_id, season, year, phase);
