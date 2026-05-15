# Finance_Ops_Dev — Decision Log

Last Updated: 2026-05-15

## Decision — Phase 12 Semantic Model Refactor

Status: APPROVED DESIGN BASELINE

Decision:
- Use curated reporting views as Power BI contract.
- Keep backend raw, clean, and snapshot layers for audit and pipeline only.
- Load only curated Fact, Dim, and Control tables into Power BI.
- Keep Control_Current_KPI and Control_Movement_KPI disconnected.
- Avoid active fact-to-fact relationships.
- Use Dim_BC to support drill-through and issue detail relationships.
- Keep Dim_Date active to movement fact only.
- Avoid active Dim_Date relationship to latest/current fact.
- Use canonical minimal DAX measure set.
- Do not create by-PIC, by-customer, or by-division measures.

Reason:
- Reduce ambiguity below 3%.
- Reduce redundant measure risk below 2%.
- Improve semantic model maintainability.
- Keep KPI reconciliation auditable.

Validation:
- NEEDS REVIEW until implemented and reconciled in PBIX.

---

## Decision — Add Synthetic UNCLASSIFIED Row to reporting.dim_pic

Marker: PHASE_12_SQL_VALIDATION_DECISION_APPEND_2026_05_15

Updated: 2026-05-15

Status: APPROVED

Decision:
- Add synthetic `UNCLASSIFIED` row to `reporting.dim_pic`.

Reason:
- Fact tables contain 12 rows where `pic_internal_code = 'UNCLASSIFIED'`.
- `clean.clean_pic_list` does not contain an `UNCLASSIFIED` PIC row.
- Without this row, Power BI Dim_PIC relationship creates orphan keys.
- UNCLASSIFIED is a correction bucket and must be visible in the model.

Implementation:
- `reporting.dim_pic` is built from `clean.clean_pic_list`.
- If `UNCLASSIFIED` does not exist in clean PIC list, the reporting view adds it.
- The row uses:
  - pic_code = UNCLASSIFIED
  - pic_full_name = UNCLASSIFIED - PIC not input in ERP
  - division_code = UNCLASSIFIED
  - pic_status = ACTIVE
  - is_unclassified_pic = TRUE

Validation:
- Dim_PIC rows = 70
- unclassified_row_count = 1
- Fact_Current_BC orphan_pic_count = 0
- Fact_Movement_BC orphan_pic_count = 0

Validation Result:
- PASS

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
