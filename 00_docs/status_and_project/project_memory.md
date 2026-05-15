# Finance_Ops_Dev — Project Memory

Last Updated: 2026-05-15

## Active Project Mode

Finance_Ops_Project Mode

## Active Phase

Phase 12 — Power BI Semantic Model Build / Relationship Setup

## Current Memory Update

The project has approved a Phase 12 semantic model refactor.

Rules now active:
- Use terminal-first / script-first documentation patching.
- Avoid manual copy-editing repository files for major updates.
- Keep progress_log.md cumulative from Phase 0.
- Use Python-first file generation.
- Write UTF-8 without BOM.
- Use curated reporting views for Power BI.
- Do not load raw, clean fact, snapshot base, or issue base tables into main PBIX model.
- Keep KPI control tables disconnected.
- Use canonical DAX measures only.
- Avoid redundant by-PIC, by-customer, by-division measures.
- Movement trend is not meaningful until latest-per-day distinct_snapshot_dates >= 2.

## Current Semantic Model Baseline

Power BI model:
- Dim_Date
- Dim_PIC
- Dim_BC
- Fact_Current_BC
- Fact_Movement_BC
- Fact_Issue_Current
- Control_Current_KPI
- Control_Movement_KPI
- _Measures

## Current DAX Baseline

Use prefixes:
- Current
- Control
- Recon
- Movement

Do not use billing_status <> "BILLED" as open backlog logic.
Use is_open_unbilled and open_rab_exposure_amount.

---

## Memory Update — Phase 12 SQL Validation Result

Marker: PHASE_12_SQL_VALIDATION_PROJECT_MEMORY_APPEND_2026_05_15

Updated: 2026-05-15

Phase 12 SQL reporting layer validation has passed structurally.

Validated:
- reporting objects exist
- fact grains are stable
- dimension keys are unique
- orphan keys are resolved
- KPI reconciliation passes
- movement source is structurally safe

Important decision:
- `reporting.dim_pic` includes synthetic `UNCLASSIFIED` row.
- This prevents orphan PIC keys in Power BI.
- UNCLASSIFIED remains correction bucket, not PIC performance penalty.

Current validation state:
- PASS STRUCTURE ONLY
- Full Phase 12 PASS still requires PBIX relationship validation and Power BI KPI card reconciliation.

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
