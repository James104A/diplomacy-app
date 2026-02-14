CREATE TABLE game_states (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id                 UUID            NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    phase                   VARCHAR(20)     NOT NULL,
    season                  VARCHAR(10)     NOT NULL,
    year                    INTEGER         NOT NULL,
    phase_label             VARCHAR(30)     NOT NULL,
    units                   JSONB           NOT NULL,
    supply_centers          JSONB           NOT NULL,
    dislodged_units         JSONB,
    standoff_territories    JSONB,
    is_initial              BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_game_states_chronological ON game_states (game_id, year, season, phase);
CREATE INDEX idx_game_states_initial ON game_states (game_id) WHERE is_initial = TRUE;
