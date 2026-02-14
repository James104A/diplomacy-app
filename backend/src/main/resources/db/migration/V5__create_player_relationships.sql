CREATE TABLE player_relationships (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    player_a_id         UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    player_b_id         UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    relationship_type   VARCHAR(50)     NOT NULL,
    verified            BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_relationship_pair UNIQUE (player_a_id, player_b_id),
    CONSTRAINT chk_no_self_relationship CHECK (player_a_id != player_b_id)
);
