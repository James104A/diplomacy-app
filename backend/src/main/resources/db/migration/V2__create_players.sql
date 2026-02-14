CREATE TABLE players (
    id                    UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name          VARCHAR(50)     NOT NULL,
    email                 VARCHAR(255)    NOT NULL,
    password_hash         VARCHAR(255),
    auth_provider         VARCHAR(20)     NOT NULL CHECK (auth_provider IN ('EMAIL', 'APPLE', 'GOOGLE')),
    avatar_url            VARCHAR(500),

    -- Ratings
    elo_classic           INTEGER         NOT NULL DEFAULT 1000,
    elo_1v1               INTEGER         NOT NULL DEFAULT 1000,
    elo_variant           INTEGER         NOT NULL DEFAULT 1000,
    peak_elo_classic      INTEGER         NOT NULL DEFAULT 1000,
    rank_tier             VARCHAR(20)     NOT NULL DEFAULT 'UNRANKED',
    placement_remaining   INTEGER         NOT NULL DEFAULT 5,

    -- Reliability
    reliability_score     DECIMAL(5,2)    NOT NULL DEFAULT 100.00,
    total_phases          INTEGER         NOT NULL DEFAULT 0,
    missed_deadlines      INTEGER         NOT NULL DEFAULT 0,
    abandoned_games       INTEGER         NOT NULL DEFAULT 0,
    is_restricted         BOOLEAN         NOT NULL DEFAULT FALSE,

    -- Stats
    games_played          INTEGER         NOT NULL DEFAULT 0,
    games_won             INTEGER         NOT NULL DEFAULT 0,
    games_drawn           INTEGER         NOT NULL DEFAULT 0,

    -- Timestamps
    created_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at            TIMESTAMPTZ
);

-- Unique constraints
ALTER TABLE players ADD CONSTRAINT uq_players_email UNIQUE (email);
ALTER TABLE players ADD CONSTRAINT uq_players_display_name UNIQUE (display_name);

-- Indexes
CREATE INDEX idx_players_elo_classic ON players (elo_classic);
CREATE INDEX idx_players_leaderboard ON players (rank_tier, elo_classic DESC);
CREATE INDEX idx_players_active ON players (deleted_at) WHERE deleted_at IS NULL;
