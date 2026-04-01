# Architecture Notes

## Main Data Path

1. `main.py` loads `.env`, configures logging, opens the PostgreSQL pool, and connects to MQTT.
2. `handle_connect()` subscribes to one or more MQTT topics from `MQTT_TOPIC`.
3. `handle_message()` splits processing by topic type:
   - `/json/`: lightweight JSON handling, then ignored
   - `/stat/` and `/tele/`: update MQTT status fields in `node_details`
   - protobuf messages: parsed as `ServiceEnvelope` and `MeshPacket`
4. Protobuf observations are deduplicated through the `messages` table using `packet.id` plus `reporting_gateway`.
5. `MessageProcessor.process()` optionally decrypts packet payloads, updates node-heard topic/channel data, stores generic packet metadata in `mesh_packet_metrics`, and dispatches to the port-specific processor.
6. Per-port processors update `node_details`, `node_neighbors`, `position_metrics`, and the telemetry hypertables.

## Important Files

- `main.py`: application entrypoint and MQTT handling
- `exporter/processor/processor_base.py`: shared processing pipeline and packet metadata storage
- `exporter/processor/processors.py`: Meshtastic port handlers
- `exporter/db_handler.py`: database write helpers
- `docker/timescaledb/init.sql`: source of truth for fresh database initialization

## Compatibility Notes

- The code intentionally supports both `meshtastic.*` and `meshtastic.protobuf.*` imports.
- Packet ingestion depends on topic parsing, optional decryption, and schema assumptions staying aligned.
- Grafana dashboards depend on stable table and column names from the SQL files.
