-- Change phase_length from INTERVAL to BIGINT (seconds)
-- Must drop the index first since idx_games_browser includes phase_length
DROP INDEX IF EXISTS idx_games_browser;
ALTER TABLE games DROP COLUMN phase_length;
ALTER TABLE games ADD COLUMN phase_length BIGINT NOT NULL DEFAULT 86400;
CREATE INDEX idx_games_browser ON games (status, visibility, is_ranked, phase_length);
