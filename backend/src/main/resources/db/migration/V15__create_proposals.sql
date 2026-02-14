CREATE TABLE proposals (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id          UUID            NOT NULL UNIQUE REFERENCES messages(id) ON DELETE CASCADE,
    proposer_power      VARCHAR(20)     NOT NULL,
    recipient_power     VARCHAR(20)     NOT NULL,
    my_commitments      JSONB           NOT NULL,
    your_commitments    JSONB           NOT NULL,
    status              VARCHAR(20)     NOT NULL DEFAULT 'PENDING'
                                        CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED')),
    responded_at        TIMESTAMPTZ
);
