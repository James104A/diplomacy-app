CREATE TABLE resolved_phases (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id                 UUID            NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    before_state_id         UUID            NOT NULL REFERENCES game_states(id),
    after_state_id          UUID            NOT NULL REFERENCES game_states(id),
    phase                   VARCHAR(20)     NOT NULL,
    season                  VARCHAR(10)     NOT NULL,
    year                    INTEGER         NOT NULL,
    phase_label             VARCHAR(30)     NOT NULL,
    all_orders              JSONB           NOT NULL,
    resolved_orders         JSONB           NOT NULL,
    supply_center_changes   JSONB,
    eliminations            VARCHAR(20)[],
    resolution_steps        JSONB,
    resolved_at             TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_resolved_phases_game ON resolved_phases (game_id, year, season, phase);
