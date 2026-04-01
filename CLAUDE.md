# CLAUDE.md

This file is for any AI coding or review assistant working in this repository, not only Claude.

## Mission

This project ingests Meshtastic MQTT traffic, decodes protobuf packets, stores telemetry and network data in TimescaleDB/PostgreSQL, and ships Grafana dashboards on top of that data.

High-level flow:

`MQTT broker -> main.py -> MessageProcessor -> per-port processors -> SQL tables -> Grafana dashboards`

## Start Here

Before making changes or giving a broad review, read the focused docs under `agent_docs/`:

- `agent_docs/reviewing.md`: what counts as a full-project review and what must be inspected
- `agent_docs/architecture.md`: runtime packet flow, key files, and data-path overview
- `agent_docs/operations.md`: validation commands, deployment behavior, and repo-specific gotchas

## Core Expectations

- Do not claim a "full review" unless you inspected Python runtime code, SQL schema and migrations, Docker/deployment files, Grafana provisioning, workflows, scripts, and docs.
- Prefer findings about correctness, schema compatibility, ingestion integrity, migration safety, dashboard breakage, and operational regressions over style nits.
- Keep changes aligned with the current architecture unless the task explicitly asks for a redesign.
- When behavior changes, update code, SQL, dashboards, scripts, and docs together if they are affected.

## Quick Repo Map

- `main.py`: MQTT connection, subscription, deduplication, and dispatch into processing
- `exporter/processor/processor_base.py`: decryption, client lookup, generic packet storage, processor dispatch
- `exporter/processor/processors.py`: per-port Meshtastic handlers
- `exporter/db_handler.py`: inserts into telemetry and packet tables
- `docker/timescaledb/`: schema source and incremental migrations
- `docker/grafana/provisioning/`: datasource and dashboard definitions
- `docker-compose.yml`: local stack topology
- `.github/workflows/`: current CI behavior

## Keep In Mind

- This repo has little automated test coverage; the main CI check is whether Docker Compose starts and stays healthy.
- `docker/exporter/Dockerfile.exporter` copies `.env` into the image, so config edits can be build-affecting.
- `meshtastic.*` and `meshtastic.protobuf.*` imports are both supported in the codebase; preserve compatibility unless the task explicitly changes that contract.
