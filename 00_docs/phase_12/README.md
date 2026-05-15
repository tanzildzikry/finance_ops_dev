# Phase 12 Documentation — Power BI Semantic Model Refactor

This folder contains Phase 12-specific documentation for Finance_Ops_Dev.

## Status

Current status: SQL REPORTING LAYER PASS STRUCTURE ONLY

Full Phase 12 PASS still requires:
- Power BI table load validation
- relationship setup validation
- canonical DAX measure validation
- Power BI KPI card reconciliation
- user final validation

## Files

| File | Purpose |
|---|---|
| phase_12_semantic_model_blueprint.md | Approved Phase 12 semantic model design |
| phase_12_powerbi_naming_relationship_and_measure_contract.md | Active Phase 12 Power BI semantic model contract covering table naming, approved relationships, disconnected control tables, canonical measure naming, DAX logic guardrails, reporting-view-only load rule, and PBIX validation checklist |
| phase_12_relationship_matrix.md | Approved Power BI relationship matrix |
| phase_12_powerbi_validation_checklist.md | Phase 12 Power BI validation checklist |
| phase_12_measure_refactor_notes.md | Canonical DAX measure refactor notes |
| phase_12_technical_patch_README.md | Phase 12 technical SQL/DAX patch summary |

## Important Rules

- Keep progress_log.md cumulative from Phase 0.
- Keep HANDOVER_TO_NEW_CHAT.md cumulative / append-safe.
- Keep current_status.md, project_memory.md, and decision_log.md in 00_docs root because they are global project-control files.
- Phase-specific documentation belongs in this folder.
- Do not interpret movement trend until latest-per-day distinct_snapshot_dates >= 2.
