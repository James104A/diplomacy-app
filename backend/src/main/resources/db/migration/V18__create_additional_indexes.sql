-- Additional composite and covering indexes for hot query paths
-- per Data Models spec Section 11.1

-- Dashboard: player's active games with game details
CREATE INDEX idx_game_players_dashboard ON game_players (player_id, game_id)
    INCLUDE (power, supply_center_count, orders_submitted, unread_message_count);

-- Game browser: open games sorted by creation
CREATE INDEX idx_games_open_browse ON games (created_at DESC)
    WHERE status = 'WAITING_FOR_PLAYERS' AND visibility = 'PUBLIC';

-- Deadline scheduler: games needing phase resolution
CREATE INDEX idx_games_pending_deadline ON games (phase_deadline)
    WHERE status = 'IN_PROGRESS' AND phase_deadline IS NOT NULL;

-- Resolved phases: chronological retrieval for replay
CREATE INDEX idx_resolved_phases_chronological ON resolved_phases (game_id, year, season);

-- Conversations: lookup by game and type for auto-creation check
CREATE INDEX idx_conversations_game_type ON conversations (game_id, type);

-- Messages: recent messages per conversation for inbox preview
CREATE INDEX idx_messages_recent ON messages (conversation_id, sent_at DESC)
    INCLUDE (sender_power, type, content);
