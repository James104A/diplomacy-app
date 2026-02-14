-- Classic Diplomacy map seed data
-- 75 territories, adjacencies, 34 supply centers, starting positions
-- Per Adjudication Engine Spec Section 2.1 and Section 9.1

-- ============================================================
-- MAP DEFINITION TABLES
-- ============================================================

CREATE TABLE territories (
    id                  VARCHAR(10)     PRIMARY KEY,
    name                VARCHAR(100)    NOT NULL,
    type                VARCHAR(10)     NOT NULL CHECK (type IN ('LAND', 'SEA', 'COAST')),
    is_supply_center    BOOLEAN         NOT NULL DEFAULT FALSE,
    home_center         VARCHAR(20),
    parent_territory    VARCHAR(10),
    map_id              VARCHAR(20)     NOT NULL DEFAULT 'CLASSIC'
);

CREATE TABLE adjacencies (
    territory_id        VARCHAR(10)     NOT NULL REFERENCES territories(id),
    target_id           VARCHAR(10)     NOT NULL REFERENCES territories(id),
    unit_types          VARCHAR(20)[]   NOT NULL,
    PRIMARY KEY (territory_id, target_id)
);

CREATE TABLE starting_positions (
    map_id              VARCHAR(20)     NOT NULL DEFAULT 'CLASSIC',
    power               VARCHAR(20)     NOT NULL,
    territory_id        VARCHAR(10)     NOT NULL REFERENCES territories(id),
    unit_type           VARCHAR(10)     NOT NULL CHECK (unit_type IN ('ARMY', 'FLEET')),
    PRIMARY KEY (map_id, power, territory_id)
);

CREATE INDEX idx_territories_map ON territories (map_id);

-- ============================================================
-- INLAND TERRITORIES (14)
-- ============================================================

INSERT INTO territories (id, name, type, is_supply_center, home_center) VALUES
('BOH', 'Bohemia',    'LAND', FALSE, NULL),
('BUR', 'Burgundy',   'LAND', FALSE, NULL),
('GAL', 'Galicia',    'LAND', FALSE, NULL),
('RUH', 'Ruhr',       'LAND', FALSE, NULL),
('SIL', 'Silesia',    'LAND', FALSE, NULL),
('TYR', 'Tyrolia',    'LAND', FALSE, NULL),
('UKR', 'Ukraine',    'LAND', FALSE, NULL),
('BUD', 'Budapest',   'LAND', TRUE,  'AUSTRIA'),
('MOS', 'Moscow',     'LAND', TRUE,  'RUSSIA'),
('MUN', 'Munich',     'LAND', TRUE,  'GERMANY'),
('PAR', 'Paris',      'LAND', TRUE,  'FRANCE'),
('SER', 'Serbia',     'LAND', TRUE,  NULL),
('VIE', 'Vienna',     'LAND', TRUE,  'AUSTRIA'),
('WAR', 'Warsaw',     'LAND', TRUE,  'RUSSIA');

-- ============================================================
-- COASTAL TERRITORIES (43 including multi-coast sub-entries)
-- ============================================================

INSERT INTO territories (id, name, type, is_supply_center, home_center) VALUES
-- Home supply centers
('ANK', 'Ankara',         'COAST', TRUE,  'TURKEY'),
('BER', 'Berlin',         'COAST', TRUE,  'GERMANY'),
('BRE', 'Brest',          'COAST', TRUE,  'FRANCE'),
('CON', 'Constantinople', 'COAST', TRUE,  'TURKEY'),
('EDI', 'Edinburgh',      'COAST', TRUE,  'ENGLAND'),
('KIE', 'Kiel',           'COAST', TRUE,  'GERMANY'),
('LON', 'London',         'COAST', TRUE,  'ENGLAND'),
('LVP', 'Liverpool',      'COAST', TRUE,  'ENGLAND'),
('MAR', 'Marseilles',     'COAST', TRUE,  'FRANCE'),
('NAP', 'Naples',         'COAST', TRUE,  'ITALY'),
('ROM', 'Rome',           'COAST', TRUE,  'ITALY'),
('SEV', 'Sevastopol',     'COAST', TRUE,  'RUSSIA'),
('SMY', 'Smyrna',         'COAST', TRUE,  'TURKEY'),
('TRI', 'Trieste',        'COAST', TRUE,  'AUSTRIA'),
('VEN', 'Venice',         'COAST', TRUE,  'ITALY'),
-- Multi-coast parents
('BUL', 'Bulgaria',       'COAST', TRUE,  NULL),
('SPA', 'Spain',          'COAST', TRUE,  NULL),
('STP', 'St. Petersburg', 'COAST', TRUE,  'RUSSIA'),
-- Neutral supply centers
('BEL', 'Belgium',        'COAST', TRUE,  NULL),
('DEN', 'Denmark',        'COAST', TRUE,  NULL),
('GRE', 'Greece',         'COAST', TRUE,  NULL),
('HOL', 'Holland',        'COAST', TRUE,  NULL),
('NWY', 'Norway',         'COAST', TRUE,  NULL),
('POR', 'Portugal',       'COAST', TRUE,  NULL),
('RUM', 'Rumania',        'COAST', TRUE,  NULL),
('SWE', 'Sweden',         'COAST', TRUE,  NULL),
('TUN', 'Tunis',          'COAST', TRUE,  NULL),
-- Non-supply center coasts
('ALB', 'Albania',        'COAST', FALSE, NULL),
('APU', 'Apulia',         'COAST', FALSE, NULL),
('ARM', 'Armenia',        'COAST', FALSE, NULL),
('CLY', 'Clyde',          'COAST', FALSE, NULL),
('FIN', 'Finland',        'COAST', FALSE, NULL),
('GAS', 'Gascony',        'COAST', FALSE, NULL),
('LVN', 'Livonia',        'COAST', FALSE, NULL),
('NAF', 'North Africa',   'COAST', FALSE, NULL),
('PIC', 'Picardy',        'COAST', FALSE, NULL),
('PIE', 'Piedmont',       'COAST', FALSE, NULL),
('PRU', 'Prussia',        'COAST', FALSE, NULL),
('SYR', 'Syria',          'COAST', FALSE, NULL),
('TUS', 'Tuscany',        'COAST', FALSE, NULL),
('WAL', 'Wales',          'COAST', FALSE, NULL),
('YOR', 'Yorkshire',      'COAST', FALSE, NULL);

-- Multi-coast sub-territories
INSERT INTO territories (id, name, type, is_supply_center, home_center, parent_territory) VALUES
('BUL_EC', 'Bulgaria (EC)',       'COAST', FALSE, NULL, 'BUL'),
('BUL_SC', 'Bulgaria (SC)',       'COAST', FALSE, NULL, 'BUL'),
('SPA_NC', 'Spain (NC)',          'COAST', FALSE, NULL, 'SPA'),
('SPA_SC', 'Spain (SC)',          'COAST', FALSE, NULL, 'SPA'),
('STP_NC', 'St. Petersburg (NC)', 'COAST', FALSE, NULL, 'STP'),
('STP_SC', 'St. Petersburg (SC)', 'COAST', FALSE, NULL, 'STP');

-- ============================================================
-- SEA ZONES (18)
-- ============================================================

INSERT INTO territories (id, name, type) VALUES
('ADR', 'Adriatic Sea',            'SEA'),
('AEG', 'Aegean Sea',              'SEA'),
('BAL', 'Baltic Sea',              'SEA'),
('BAR', 'Barents Sea',             'SEA'),
('BLA', 'Black Sea',               'SEA'),
('BOT', 'Gulf of Bothnia',         'SEA'),
('EAS', 'Eastern Mediterranean',   'SEA'),
('ENG', 'English Channel',         'SEA'),
('GOL', 'Gulf of Lyon',            'SEA'),
('HEL', 'Heligoland Bight',       'SEA'),
('ION', 'Ionian Sea',              'SEA'),
('IRI', 'Irish Sea',               'SEA'),
('MAO', 'Mid-Atlantic Ocean',      'SEA'),
('NAO', 'North Atlantic Ocean',    'SEA'),
('NTH', 'North Sea',               'SEA'),
('NWG', 'Norwegian Sea',           'SEA'),
('SKA', 'Skagerrak',               'SEA'),
('TYS', 'Tyrrhenian Sea',          'SEA'),
('WES', 'Western Mediterranean',   'SEA');

-- ============================================================
-- ADJACENCIES
-- ============================================================
-- Using a temp table for one-directional inserts, then mirroring.

CREATE TEMP TABLE _adj_raw (
    from_id     VARCHAR(10),
    to_id       VARCHAR(10),
    unit_types  VARCHAR(20)[]
);

INSERT INTO _adj_raw (from_id, to_id, unit_types) VALUES
-- ===== INLAND-INLAND and INLAND-COASTAL (army only) =====
('BOH', 'MUN', '{ARMY}'),
('BOH', 'SIL', '{ARMY}'),
('BOH', 'GAL', '{ARMY}'),
('BOH', 'VIE', '{ARMY}'),
('BOH', 'TYR', '{ARMY}'),
('BUD', 'VIE', '{ARMY}'),
('BUD', 'TRI', '{ARMY}'),
('BUD', 'SER', '{ARMY}'),
('BUD', 'RUM', '{ARMY}'),
('BUD', 'GAL', '{ARMY}'),
('BUR', 'PAR', '{ARMY}'),
('BUR', 'PIC', '{ARMY}'),
('BUR', 'BEL', '{ARMY}'),
('BUR', 'RUH', '{ARMY}'),
('BUR', 'MUN', '{ARMY}'),
('BUR', 'MAR', '{ARMY}'),
('BUR', 'GAS', '{ARMY}'),
('GAL', 'VIE', '{ARMY}'),
('GAL', 'WAR', '{ARMY}'),
('GAL', 'UKR', '{ARMY}'),
('GAL', 'RUM', '{ARMY}'),
('GAL', 'SIL', '{ARMY}'),
('MOS', 'UKR', '{ARMY}'),
('MOS', 'WAR', '{ARMY}'),
('MOS', 'LVN', '{ARMY}'),
('MOS', 'SEV', '{ARMY}'),
('MOS', 'STP', '{ARMY}'),
('MOS', 'FIN', '{ARMY}'),
('MUN', 'RUH', '{ARMY}'),
('MUN', 'KIE', '{ARMY}'),
('MUN', 'BER', '{ARMY}'),
('MUN', 'SIL', '{ARMY}'),
('MUN', 'TYR', '{ARMY}'),
('PAR', 'PIC', '{ARMY}'),
('PAR', 'BRE', '{ARMY}'),
('PAR', 'GAS', '{ARMY}'),
('RUH', 'BEL', '{ARMY}'),
('RUH', 'HOL', '{ARMY}'),
('RUH', 'KIE', '{ARMY}'),
('SER', 'TRI', '{ARMY}'),
('SER', 'ALB', '{ARMY}'),
('SER', 'GRE', '{ARMY}'),
('SER', 'BUL', '{ARMY}'),
('SER', 'RUM', '{ARMY}'),
('SIL', 'WAR', '{ARMY}'),
('SIL', 'PRU', '{ARMY}'),
('SIL', 'BER', '{ARMY}'),
('TYR', 'VIE', '{ARMY}'),
('TYR', 'TRI', '{ARMY}'),
('TYR', 'VEN', '{ARMY}'),
('TYR', 'PIE', '{ARMY}'),
('UKR', 'WAR', '{ARMY}'),
('UKR', 'SEV', '{ARMY}'),
('UKR', 'RUM', '{ARMY}'),
('WAR', 'PRU', '{ARMY}'),
('WAR', 'LVN', '{ARMY}'),

-- ===== COASTAL-COASTAL (army+fleet where coast touches) =====
('ALB', 'TRI', '{ARMY,FLEET}'),
('ALB', 'GRE', '{ARMY,FLEET}'),
('ALB', 'ION', '{FLEET}'),
('ALB', 'ADR', '{FLEET}'),
('ANK', 'CON', '{ARMY,FLEET}'),
('ANK', 'ARM', '{ARMY,FLEET}'),
('ANK', 'BLA', '{FLEET}'),
('APU', 'VEN', '{ARMY,FLEET}'),
('APU', 'ROM', '{ARMY}'),
('APU', 'NAP', '{ARMY,FLEET}'),
('APU', 'ADR', '{FLEET}'),
('APU', 'ION', '{FLEET}'),
('ARM', 'SEV', '{ARMY,FLEET}'),
('ARM', 'SYR', '{ARMY,FLEET}'),
('ARM', 'ANK', '{ARMY,FLEET}'),
('ARM', 'BLA', '{FLEET}'),
('BEL', 'HOL', '{ARMY,FLEET}'),
('BEL', 'PIC', '{ARMY,FLEET}'),
('BEL', 'ENG', '{FLEET}'),
('BEL', 'NTH', '{FLEET}'),
('BER', 'PRU', '{ARMY,FLEET}'),
('BER', 'KIE', '{ARMY,FLEET}'),
('BER', 'BAL', '{FLEET}'),
('BRE', 'PIC', '{ARMY,FLEET}'),
('BRE', 'GAS', '{ARMY,FLEET}'),
('BRE', 'ENG', '{FLEET}'),
('BRE', 'MAO', '{FLEET}'),
('CLY', 'EDI', '{ARMY,FLEET}'),
('CLY', 'LVP', '{ARMY,FLEET}'),
('CLY', 'NAO', '{FLEET}'),
('CLY', 'NWG', '{FLEET}'),
('CON', 'SMY', '{ARMY,FLEET}'),
('CON', 'BUL', '{ARMY}'),
('CON', 'BUL_SC', '{FLEET}'),
('CON', 'BUL_EC', '{FLEET}'),
('CON', 'AEG', '{FLEET}'),
('CON', 'BLA', '{FLEET}'),
('DEN', 'KIE', '{ARMY,FLEET}'),
('DEN', 'SWE', '{ARMY,FLEET}'),
('DEN', 'NTH', '{FLEET}'),
('DEN', 'SKA', '{FLEET}'),
('DEN', 'BAL', '{FLEET}'),
('DEN', 'HEL', '{FLEET}'),
('EDI', 'YOR', '{ARMY}'),
('EDI', 'LVP', '{ARMY}'),
('EDI', 'CLY', '{ARMY,FLEET}'),
('EDI', 'NTH', '{FLEET}'),
('EDI', 'NWG', '{FLEET}'),
('FIN', 'NWY', '{ARMY}'),
('FIN', 'SWE', '{ARMY,FLEET}'),
('FIN', 'STP', '{ARMY}'),
('FIN', 'STP_SC', '{FLEET}'),
('FIN', 'BOT', '{FLEET}'),
('GAS', 'MAR', '{ARMY}'),
('GAS', 'SPA', '{ARMY}'),
('GAS', 'SPA_NC', '{FLEET}'),
('GAS', 'MAO', '{FLEET}'),
('GRE', 'BUL', '{ARMY}'),
('GRE', 'BUL_SC', '{FLEET}'),
('GRE', 'ION', '{FLEET}'),
('GRE', 'AEG', '{FLEET}'),
('HOL', 'HEL', '{FLEET}'),
('HOL', 'NTH', '{FLEET}'),
('KIE', 'HOL', '{ARMY,FLEET}'),
('KIE', 'HEL', '{FLEET}'),
('KIE', 'BAL', '{FLEET}'),
('LON', 'YOR', '{ARMY}'),
('LON', 'WAL', '{ARMY}'),
('LON', 'ENG', '{FLEET}'),
('LON', 'NTH', '{FLEET}'),
('LVN', 'STP', '{ARMY}'),
('LVN', 'STP_SC', '{FLEET}'),
('LVN', 'PRU', '{ARMY,FLEET}'),
('LVN', 'BAL', '{FLEET}'),
('LVN', 'BOT', '{FLEET}'),
('LVP', 'YOR', '{ARMY}'),
('LVP', 'WAL', '{ARMY,FLEET}'),
('LVP', 'CLY', '{ARMY,FLEET}'),
('LVP', 'IRI', '{FLEET}'),
('LVP', 'NAO', '{FLEET}'),
('MAR', 'PIE', '{ARMY}'),
('MAR', 'SPA', '{ARMY}'),
('MAR', 'SPA_SC', '{FLEET}'),
('MAR', 'GOL', '{FLEET}'),
('NAF', 'TUN', '{ARMY,FLEET}'),
('NAF', 'MAO', '{FLEET}'),
('NAF', 'WES', '{FLEET}'),
('NAP', 'ROM', '{ARMY,FLEET}'),
('NAP', 'ION', '{FLEET}'),
('NAP', 'TYS', '{FLEET}'),
('NWY', 'SWE', '{ARMY,FLEET}'),
('NWY', 'STP', '{ARMY}'),
('NWY', 'STP_NC', '{FLEET}'),
('NWY', 'NTH', '{FLEET}'),
('NWY', 'NWG', '{FLEET}'),
('NWY', 'SKA', '{FLEET}'),
('NWY', 'BAR', '{FLEET}'),
('PIC', 'ENG', '{FLEET}'),
('PIE', 'VEN', '{ARMY}'),
('PIE', 'TUS', '{ARMY,FLEET}'),
('PIE', 'GOL', '{FLEET}'),
('POR', 'SPA', '{ARMY}'),
('POR', 'SPA_NC', '{FLEET}'),
('POR', 'SPA_SC', '{FLEET}'),
('POR', 'MAO', '{FLEET}'),
('PRU', 'BAL', '{FLEET}'),
('ROM', 'VEN', '{ARMY}'),
('ROM', 'TUS', '{ARMY,FLEET}'),
('ROM', 'TYS', '{FLEET}'),
('RUM', 'BUL', '{ARMY}'),
('RUM', 'BUL_EC', '{FLEET}'),
('RUM', 'SEV', '{ARMY,FLEET}'),
('RUM', 'BLA', '{FLEET}'),
('SEV', 'BLA', '{FLEET}'),
('SMY', 'SYR', '{ARMY,FLEET}'),
('SMY', 'ARM', '{ARMY}'),
('SMY', 'CON', '{ARMY,FLEET}'),
('SMY', 'AEG', '{FLEET}'),
('SMY', 'EAS', '{FLEET}'),
('SPA', 'POR', '{ARMY}'),
('SPA_NC', 'MAO', '{FLEET}'),
('SPA_SC', 'MAO', '{FLEET}'),
('SPA_SC', 'GOL', '{FLEET}'),
('SPA_SC', 'WES', '{FLEET}'),
('STP_NC', 'BAR', '{FLEET}'),
('STP_NC', 'NWY', '{FLEET}'),
('STP_SC', 'BOT', '{FLEET}'),
('STP_SC', 'FIN', '{FLEET}'),
('STP_SC', 'LVN', '{FLEET}'),
('SWE', 'DEN', '{ARMY,FLEET}'),
('SWE', 'NWY', '{ARMY,FLEET}'),
('SWE', 'FIN', '{ARMY,FLEET}'),
('SWE', 'SKA', '{FLEET}'),
('SWE', 'BAL', '{FLEET}'),
('SWE', 'BOT', '{FLEET}'),
('SYR', 'EAS', '{FLEET}'),
('TRI', 'VEN', '{ARMY,FLEET}'),
('TRI', 'ADR', '{FLEET}'),
('TUN', 'ION', '{FLEET}'),
('TUN', 'TYS', '{FLEET}'),
('TUN', 'WES', '{FLEET}'),
('TUS', 'VEN', '{ARMY}'),
('TUS', 'GOL', '{FLEET}'),
('TUS', 'TYS', '{FLEET}'),
('WAL', 'YOR', '{ARMY}'),
('WAL', 'ENG', '{FLEET}'),
('WAL', 'IRI', '{FLEET}'),

-- ===== SEA-SEA =====
('ADR', 'ION', '{FLEET}'),
('AEG', 'ION', '{FLEET}'),
('AEG', 'EAS', '{FLEET}'),
('AEG', 'BLA', '{FLEET}'),
('BAR', 'NWG', '{FLEET}'),
('BOT', 'BAL', '{FLEET}'),
('EAS', 'ION', '{FLEET}'),
('ENG', 'IRI', '{FLEET}'),
('ENG', 'MAO', '{FLEET}'),
('ENG', 'NTH', '{FLEET}'),
('GOL', 'TYS', '{FLEET}'),
('GOL', 'WES', '{FLEET}'),
('HEL', 'NTH', '{FLEET}'),
('ION', 'TYS', '{FLEET}'),
('IRI', 'MAO', '{FLEET}'),
('IRI', 'NAO', '{FLEET}'),
('MAO', 'NAO', '{FLEET}'),
('MAO', 'WES', '{FLEET}'),
('NAO', 'NWG', '{FLEET}'),
('NTH', 'NWG', '{FLEET}'),
('NTH', 'SKA', '{FLEET}'),
('SKA', 'BAL', '{FLEET}'),
('TYS', 'WES', '{FLEET}');

-- Mirror all adjacencies (make bidirectional)
INSERT INTO adjacencies (territory_id, target_id, unit_types)
SELECT to_id, from_id, unit_types FROM _adj_raw
ON CONFLICT DO NOTHING;

INSERT INTO adjacencies (territory_id, target_id, unit_types)
SELECT from_id, to_id, unit_types FROM _adj_raw
ON CONFLICT DO NOTHING;

DROP TABLE _adj_raw;

-- ============================================================
-- STARTING POSITIONS (Spring 1901)
-- ============================================================

INSERT INTO starting_positions (power, territory_id, unit_type) VALUES
('AUSTRIA', 'VIE', 'ARMY'),
('AUSTRIA', 'BUD', 'ARMY'),
('AUSTRIA', 'TRI', 'FLEET'),
('ENGLAND', 'LON', 'FLEET'),
('ENGLAND', 'EDI', 'FLEET'),
('ENGLAND', 'LVP', 'ARMY'),
('FRANCE',  'PAR', 'ARMY'),
('FRANCE',  'MAR', 'ARMY'),
('FRANCE',  'BRE', 'FLEET'),
('GERMANY', 'BER', 'ARMY'),
('GERMANY', 'MUN', 'ARMY'),
('GERMANY', 'KIE', 'FLEET'),
('ITALY',   'ROM', 'ARMY'),
('ITALY',   'VEN', 'ARMY'),
('ITALY',   'NAP', 'FLEET'),
('RUSSIA',  'MOS', 'ARMY'),
('RUSSIA',  'WAR', 'ARMY'),
('RUSSIA',  'SEV', 'FLEET'),
('RUSSIA',  'STP_SC', 'FLEET'),
('TURKEY',  'CON', 'ARMY'),
('TURKEY',  'SMY', 'ARMY'),
('TURKEY',  'ANK', 'FLEET');
