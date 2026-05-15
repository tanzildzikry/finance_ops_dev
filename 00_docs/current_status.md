# Finance_Ops_Dev — Current Status

Last Updated: 2026-05-15

## Current Status

PASS through Phase 11.3 — Align Movement Readiness Logic

## Current Phase

Phase 12 — Power BI Semantic Model Build / Relationship Setup

Status: IN PROGRESS

## Production Readiness

NOT YET

## Active Focus

- Build curated reporting views
- Refactor Power BI semantic model
- Use canonical DAX measures
- Keep KPI control tables disconnected
- Avoid fact-to-fact relationships
- Validate current KPI cards against control view
- Keep movement trend interpretation disabled until latest-per-day distinct_snapshot_dates >= 2

## Important Sources

Current dashboard fact:
- snapshot.vw_latest_bc_daily_status_snapshot

KPI reconciliation:
- snapshot.vw_latest_snapshot_kpi_control

Movement / trend fact:
- snapshot.vw_daily_status_snapshot_latest_per_day

Movement KPI control:
- snapshot.vw_daily_kpi_control_latest_per_day

## Current Rule

Documentation and repo updates must be terminal-first / script-first where practical.

Avoid manual file editing for major patches.
