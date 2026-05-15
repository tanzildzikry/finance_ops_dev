# Finance_Ops_Dev — Current Status

Last Updated: 2026-05-15

## Current Status

PASS through Phase 11.3 — Align Movement Readiness Logic

## Current Phase

Phase 12 — Power BI Semantic Model Build / Relationship Setup

Status: SQL REPORTING LAYER PASS STRUCTURE ONLY

## Production Readiness

NOT YET

## Active Focus

Proceed to Power BI semantic model setup using validated reporting views.

## Latest Phase 12 SQL Validation

```text
OBJECT_EXISTENCE      = PASS
GRAIN_CHECK           = PASS
DIM_KEY_CHECK         = PASS
ORPHAN_KEY_CHECK      = PASS
CONTROL_TABLE_CHECK   = PASS
KPI_RECONCILIATION    = PASS
MOVEMENT_READINESS    = PASS STRUCTURE ONLY
```

## Important Sources for Power BI

Current dashboard fact:
- reporting.fact_current_bc
- source: snapshot.vw_latest_bc_daily_status_snapshot

KPI reconciliation:
- reporting.control_current_kpi
- source: snapshot.vw_latest_snapshot_kpi_control

Movement / trend fact:
- reporting.fact_movement_bc
- source: snapshot.vw_daily_status_snapshot_latest_per_day

Movement KPI control:
- reporting.control_movement_kpi
- source: snapshot.vw_daily_kpi_control_latest_per_day

Issue detail:
- reporting.fact_issue_current
- source: snapshot.vw_latest_bc_daily_issue_history

PIC dimension:
- reporting.dim_pic
- includes synthetic UNCLASSIFIED row

BC dimension:
- reporting.dim_bc

Date dimension:
- reporting.dim_date

## Movement Rule

Movement source is structurally safe.

Movement trend must not be interpreted until:

```text
latest-per-day distinct_snapshot_dates >= 2
```

Current latest-per-day distinct_snapshot_dates:

```text
1
```

## Next Required Step

Build Power BI semantic model:
- load curated reporting views
- apply relationship matrix
- create canonical DAX measures
- validate Power BI cards against control values

---

## Phase 12 — Documentation Folder Reorganization

Marker: PHASE_12_DOCS_FOLDER_REORGANIZATION_2026_05_15

Updated: 2026-05-15  
Status: PASS  
Validation Result: PASS  
Risk Level: LOW  

### Summary

Documentation structure has been reorganized for better maintainability.

### New Documentation Structure

00_docs/status_and_project/
  current_status.md
  decision_log.md
  handover_to_new_chat_v1.md
  progress_log.md
  project_memory.md

00_docs/sources/
  masked_source_profile_result.md
  masked_source_review.md
  source_data_preparation.md
  source_file_register.md

00_docs/phase_12/
  README.md
  phase_12_semantic_model_blueprint.md
  phase_12_relationship_matrix.md
  phase_12_powerbi_validation_checklist.md
  phase_12_measure_refactor_notes.md
  phase_12_technical_patch_README.md

### Decision

Global project-control documents are stored in:

00_docs/status_and_project/

Source documentation is stored in:

00_docs/sources/

Phase-specific documentation is stored in:

00_docs/phase_12/

The handover file has been renamed to:

handover_to_new_chat_v1.md

### Control

This change is documentation organization only.

No SQL, DAX, Power BI logic, KPI definition, or business rule was changed.

### Next Documentation Rule

Use the new documentation structure going forward:

- status/project updates must use 00_docs/status_and_project/
- source documentation must use 00_docs/sources/
- phase-specific documentation must use its own phase folder
- progress_log.md must remain cumulative from Phase 0
- handover_to_new_chat_v1.md must remain cumulative / append-safe
