-- Change phase_length from INTERVAL to BIGINT (seconds)
ALTER TABLE games DROP COLUMN phase_length;
ALTER TABLE games ADD COLUMN phase_length BIGINT NOT NULL DEFAULT 86400;
