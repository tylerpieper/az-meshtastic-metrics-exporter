# CLAUDE.md

This directory contains the Python ingestion and processing pipeline.

## Read This Directory As A Pipeline

- `client_details.py`: Meshtastic node metadata helpers
- `db_handler.py`: database write helpers for telemetry and packet tables
- `processor/processor_base.py`: shared packet processing, decryption, node lookup, packet metadata storage, and processor dispatch
- `processor/processors.py`: per-port handlers for Meshtastic payloads

## Review Focus

- Preserve compatibility with both `meshtastic.*` and `meshtastic.protobuf.*` imports.
- Check that new metric keys written in Python match actual SQL columns.
- Treat packet deduplication, decryption, and per-port dispatch as correctness-critical.
- Several processors are intentionally partial or stubbed; do not assume missing behavior is accidental without checking the surrounding history and docs.

## If You Change Data Shape

If you add or rename a field written from this directory, also inspect:

- `docker/timescaledb/init.sql`
- matching migration files in `docker/timescaledb/`
- Grafana dashboards under `docker/grafana/provisioning/dashboards/`
