CREATE TABLE game_players (
    game_id                     UUID            NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    player_id                   UUID            NOT NULL REFERENCES players(id),
    power                       VARCHAR(20)     NOT NULL
                                                CHECK (power IN ('ENGLAND', 'FRANCE', 'GERMANY', 'ITALY', 'AUSTRIA', 'RUSSIA', 'TURKEY')),
    is_eliminated               BOOLEAN         NOT NULL DEFAULT FALSE,
    is_ai_controlled            BOOLEAN         NOT NULL DEFAULT FALSE,
    consecutive_misses          INTEGER         NOT NULL DEFAULT 0,

    -- Denormalized for dashboard performance
    orders_submitted            BOOLEAN         NOT NULL DEFAULT FALSE,
    supply_center_count         INTEGER         NOT NULL DEFAULT 3,
    prev_supply_center_count    INTEGER         NOT NULL DEFAULT 3,
    unread_message_count        INTEGER         NOT NULL DEFAULT 0,

    joined_at                   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    PRIMARY KEY (game_id, player_id)
);

CREATE INDEX idx_game_players_player ON game_players (player_id);
CREATE UNIQUE INDEX idx_game_players_power ON game_players (game_id, power);
CREATE INDEX idx_game_players_orders ON game_players (game_id, orders_submitted);
