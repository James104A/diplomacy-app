CREATE TABLE reports (
    id                      UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id                 UUID            NOT NULL REFERENCES games(id),
    reporter_player_id      UUID            NOT NULL REFERENCES players(id),
    reported_player_id      UUID            NOT NULL REFERENCES players(id),
    category                VARCHAR(30)     NOT NULL
                                            CHECK (category IN ('COLLUSION', 'ABUSIVE_MESSAGING', 'MULTI_ACCOUNTING', 'OTHER')),
    description             TEXT            NOT NULL,
    evidence_phases         VARCHAR(30)[],
    moderation_status       VARCHAR(20)     NOT NULL DEFAULT 'OPEN'
                                            CHECK (moderation_status IN ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'DISMISSED')),
    resolution_notes        TEXT,
    resolved_by             UUID            REFERENCES players(id),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    resolved_at             TIMESTAMPTZ
);

CREATE INDEX idx_reports_status ON reports (moderation_status);
CREATE INDEX idx_reports_reported ON reports (reported_player_id);
CREATE INDEX idx_reports_game ON reports (game_id);
