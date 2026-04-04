-- Migration: retain all NeighborInfo packets instead of only the latest per node/neighbor pair.
-- Existing graph dashboards should read from node_neighbors_latest, which exposes the most recent
-- observation for each pair while node_neighbors becomes an append-only history table.

ALTER TABLE node_neighbors ADD COLUMN IF NOT EXISTS time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE node_neighbors ADD COLUMN IF NOT EXISTS packet_id BIGINT;
ALTER TABLE node_neighbors ADD COLUMN IF NOT EXISTS rx_time BIGINT;

ALTER TABLE node_neighbors DROP CONSTRAINT IF EXISTS node_neighbors_node_id_neighbor_id_key;
DROP INDEX IF EXISTS idx_unique_node_neighbor;

CREATE INDEX IF NOT EXISTS idx_node_neighbors_node_time ON node_neighbors (node_id, time DESC);
CREATE INDEX IF NOT EXISTS idx_node_neighbors_neighbor_time ON node_neighbors (neighbor_id, time DESC);
CREATE INDEX IF NOT EXISTS idx_node_neighbors_pair_time ON node_neighbors (node_id, neighbor_id, time DESC);
CREATE INDEX IF NOT EXISTS idx_node_neighbors_packet_id ON node_neighbors (packet_id);

CREATE OR REPLACE VIEW node_neighbors_latest AS
SELECT DISTINCT ON (node_id, neighbor_id)
    id,
    time,
    node_id,
    neighbor_id,
    snr,
    packet_id,
    rx_time
FROM node_neighbors
ORDER BY node_id, neighbor_id, time DESC, id DESC;
