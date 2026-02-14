CREATE TABLE player_devices (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id       UUID            NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    platform        VARCHAR(10)     NOT NULL CHECK (platform IN ('IOS', 'ANDROID')),
    push_token      VARCHAR(500)    NOT NULL,
    device_id       VARCHAR(100)    NOT NULL,
    device_model    VARCHAR(100),
    os_version      VARCHAR(50),
    app_install_id  VARCHAR(100)    NOT NULL,
    ip_hash         VARCHAR(64),
    timezone        VARCHAR(50),
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    last_seen_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_player_devices_push ON player_devices (player_id, is_active);
CREATE INDEX idx_player_devices_device ON player_devices (device_id);
CREATE INDEX idx_player_devices_install ON player_devices (app_install_id);
