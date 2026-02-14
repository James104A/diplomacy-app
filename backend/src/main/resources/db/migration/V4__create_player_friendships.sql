CREATE TABLE player_friendships (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id    UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    recipient_id    UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    status          VARCHAR(20)     NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED')),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    accepted_at     TIMESTAMPTZ,

    CONSTRAINT uq_friendship_pair UNIQUE (requester_id, recipient_id),
    CONSTRAINT chk_no_self_friend CHECK (requester_id != recipient_id)
);

CREATE INDEX idx_friendships_recipient ON player_friendships (recipient_id, status);
