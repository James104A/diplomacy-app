CREATE TABLE games (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name                    VARCHAR(100)    NOT NULL,
    status                  VARCHAR(30)     NOT NULL DEFAULT 'WAITING_FOR_PLAYERS'
                                            CHECK (status IN ('WAITING_FOR_PLAYERS', 'IN_PROGRESS', 'COMPLETED')),
    creator_id              UUID            NOT NULL REFERENCES players(id),
    map_id                  VARCHAR(20)     NOT NULL DEFAULT 'CLASSIC',

    -- Phase configuration
    phase_length            INTERVAL        NOT NULL DEFAULT INTERVAL '24 hours',
    press_rules             VARCHAR(20)     NOT NULL DEFAULT 'FULL_PRESS'
                                            CHECK (press_rules IN ('FULL_PRESS', 'GUNBOAT', 'PUBLIC_ONLY', 'CUSTOM')),
    scoring_system          VARCHAR(30)     NOT NULL DEFAULT 'DRAW_SIZE'
                                            CHECK (scoring_system IN ('DRAW_SIZE', 'SUM_OF_SQUARES', 'SURVIVOR_VP')),
    min_reliability         INTEGER         NOT NULL DEFAULT 70,
    is_ranked               BOOLEAN         NOT NULL DEFAULT TRUE,
    visibility              VARCHAR(10)     NOT NULL DEFAULT 'PUBLIC'
                                            CHECK (visibility IN ('PUBLIC', 'PRIVATE')),
    invite_code             VARCHAR(20),
    read_receipts           BOOLEAN         NOT NULL DEFAULT FALSE,
    anonymous_countries     BOOLEAN         NOT NULL DEFAULT FALSE,

    -- Current phase tracking
    current_phase           VARCHAR(20)     NOT NULL DEFAULT 'DIPLOMACY'
                                            CHECK (current_phase IN ('DIPLOMACY', 'ORDER_SUBMISSION', 'RETREAT', 'BUILD')),
    current_season          VARCHAR(10)     NOT NULL DEFAULT 'SPRING'
                                            CHECK (current_season IN ('SPRING', 'FALL')),
    current_year            INTEGER         NOT NULL DEFAULT 1901,
    phase_deadline          TIMESTAMPTZ,
    all_orders_submitted    BOOLEAN         NOT NULL DEFAULT FALSE,

    -- Result
    result                  VARCHAR(20)     CHECK (result IN ('SOLO_VICTORY', 'DRAW', 'ABANDONED')),
    winner_power            VARCHAR(20),
    winner_player_id        UUID            REFERENCES players(id),

    -- Denormalized
    player_count            INTEGER         NOT NULL DEFAULT 0,

    -- Timestamps
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    started_at              TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_games_browser ON games (status, visibility, is_ranked, phase_length);
CREATE INDEX idx_games_deadline ON games (status, phase_deadline);
CREATE UNIQUE INDEX idx_games_invite_code ON games (invite_code) WHERE invite_code IS NOT NULL;
CREATE INDEX idx_games_creator ON games (creator_id);
