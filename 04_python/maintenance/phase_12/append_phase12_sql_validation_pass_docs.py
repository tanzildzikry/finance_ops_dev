from pathlib import Path
from datetime import date

ROOT = Path.cwd()
DOCS = ROOT / "00_docs"

today = date.today().isoformat()

PROGRESS_MARKER = "PHASE_12_SQL_VALIDATION_PASS_STRUCTURE_APPEND_2026_05_15"
HANDOVER_MARKER = "PHASE_12_SQL_VALIDATION_HANDOVER_APPEND_2026_05_15"
PROJECT_MEMORY_MARKER = "PHASE_12_SQL_VALIDATION_PROJECT_MEMORY_APPEND_2026_05_15"
DECISION_MARKER = "PHASE_12_SQL_VALIDATION_DECISION_APPEND_2026_05_15"

def read_text(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Missing required file: {path}")
    return path.read_text(encoding="utf-8")

def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")

def append_section_once(path: Path, marker: str, section: str) -> None:
    original = read_text(path)

    if marker in original:
        print(f"SKIP: marker already exists in {path}")
        return

    original_line_count = len(original.splitlines())
    new_content = original.rstrip() + "\n\n" + section.strip() + "\n"
    new_line_count = len(new_content.splitlines())

    if new_line_count <= original_line_count:
        raise RuntimeError(
            f"BLOCKED: line count did not increase for {path}. "
            f"Before={original_line_count}, After={new_line_count}"
        )

    if original.strip() not in new_content:
        raise RuntimeError(f"BLOCKED: original content was not preserved for {path}")

    write_text(path, new_content)
    print(f"PASS: appended to {path}")
    print(f"Line count: {original_line_count} -> {new_line_count}")

def replace_file(path: Path, content: str) -> None:
    write_text(path, content)
    print(f"PASS: wrote {path}")

progress_section = f"""
---

## Phase 12 — SQL Reporting Views Validation Result

Marker: {PROGRESS_MARKER}

Updated: {today}  
Status: PASS STRUCTURE ONLY  
Validation Result: PASS STRUCTURE ONLY  
Risk Level: LOW  

### Summary

Phase 12 SQL reporting views and semantic model source validation have been executed successfully.

The reporting layer is structurally ready for Power BI semantic model build.

### Validation Results

```text
OBJECT_EXISTENCE      = PASS
GRAIN_CHECK           = PASS
DIM_KEY_CHECK         = PASS
ORPHAN_KEY_CHECK      = PASS
CONTROL_TABLE_CHECK   = PASS
KPI_RECONCILIATION    = PASS
MOVEMENT_READINESS    = PASS STRUCTURE ONLY
```

### Key Validation Details

```text
Fact_Current_BC:
rows = 8266
distinct_bc_number = 8266
duplicate_bc_number = 0
null_or_blank_bc_number = 0

Fact_Issue_Current:
rows = 8266
distinct_bc_number = 8266
duplicate_bc_number = 0
null_or_blank_bc_number = 0

Fact_Movement_BC:
rows = 8266
distinct_snapshot_date_bc_number = 8266
duplicate_snapshot_date_bc_number = 0
distinct_snapshot_dates = 1

Dim_BC:
rows = 8266
distinct_bc_number = 8266
duplicate_bc_number = 0

Dim_PIC:
rows = 70
distinct_pic_code = 70
duplicate_pic_code = 0
unclassified_row_count = 1

Orphan PIC:
Fact_Current_BC orphan_pic_count = 0
Fact_Movement_BC orphan_pic_count = 0

Control tables:
Control_Current_KPI rows = 1
Control_Movement_KPI rows = 1
```

### KPI Reconciliation

```text
total_bc_count:
fact = 8266
control = 8266
result = PASS

open_bc_count:
fact = 8145
control = 8145
result = PASS

open_rab_exposure_amount:
fact = 4,956,993,250,804.46
control = 4,956,993,250,804.46
result = PASS

high_risk_bc_count:
fact = 3
control = 3
result = PASS

high_risk_rab_exposure_amount:
fact = 23,820,974,461.00
control = 23,820,974,461.00
result = PASS

average_aging_open_bc:
fact = 51.0055248618784530
control = 51.0055248618784530
result = PASS
```

### Dim_PIC Patch Decision

`reporting.dim_pic` was patched to include a synthetic `UNCLASSIFIED` row.

Reason:
- `UNCLASSIFIED` exists in fact tables as correction bucket.
- `clean.clean_pic_list` did not contain `UNCLASSIFIED`.
- Without the synthetic row, Power BI relationship would have 12 orphan PIC keys.
- After patch, orphan PIC count is 0.

### Movement Readiness

```text
latest-per-day distinct_snapshot_dates = 1
validation_result = PASS STRUCTURE ONLY
```

Movement source is structurally safe, but trend insight must not be interpreted until latest-per-day distinct_snapshot_dates >= 2.

### Current Hold Point

Proceed to Power BI load and semantic relationship setup using curated reporting views.

Do not mark full Phase 12 PASS until PBIX relationship validation and Power BI card reconciliation are complete.
"""

handover_section = f"""
---

## Phase 12 Handover Update — SQL Validation Result

Marker: {HANDOVER_MARKER}

Updated: {today}

### Current Status

Phase 12 SQL reporting views validation result:

```text
PASS STRUCTURE ONLY
```

### Validation Summary

```text
OBJECT_EXISTENCE      = PASS
GRAIN_CHECK           = PASS
DIM_KEY_CHECK         = PASS
ORPHAN_KEY_CHECK      = PASS
CONTROL_TABLE_CHECK   = PASS
KPI_RECONCILIATION    = PASS
MOVEMENT_READINESS    = PASS STRUCTURE ONLY
```

### Critical Detail

`reporting.dim_pic` now includes a synthetic `UNCLASSIFIED` row.

This is required because:
- UNCLASSIFIED is a correction bucket.
- UNCLASSIFIED is not PIC performance penalty.
- Fact tables contain 12 UNCLASSIFIED PIC rows.
- Power BI relationship must not have orphan PIC keys.

After patch:
- Dim_PIC rows = 70
- unclassified_row_count = 1
- Fact_Current_BC orphan_pic_count = 0
- Fact_Movement_BC orphan_pic_count = 0

### Movement Rule

Movement readiness remains:

```text
PASS STRUCTURE ONLY
```

Reason:
- latest-per-day distinct_snapshot_dates = 1

Do not interpret movement trend until latest-per-day distinct_snapshot_dates >= 2.

### Next Step

Proceed to Power BI load:
- Fact_Current_BC
- Fact_Movement_BC
- Fact_Issue_Current
- Control_Current_KPI
- Control_Movement_KPI
- Dim_PIC
- Dim_BC
- Dim_Date
- _Measures

Then validate relationship setup and KPI cards in PBIX.
"""

project_memory_section = f"""
---

## Memory Update — Phase 12 SQL Validation Result

Marker: {PROJECT_MEMORY_MARKER}

Updated: {today}

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
"""

decision_section = f"""
---

## Decision — Add Synthetic UNCLASSIFIED Row to reporting.dim_pic

Marker: {DECISION_MARKER}

Updated: {today}

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
"""

current_status = f"""# Finance_Ops_Dev — Current Status

Last Updated: {today}

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
"""

validation_checklist_append = f"""
---

## Phase 12 SQL Reporting Layer Validation Result

Marker: PHASE_12_SQL_VALIDATION_CHECKLIST_APPEND_2026_05_15

Updated: {today}

### SQL Reporting Layer Status

```text
PASS STRUCTURE ONLY
```

### Completed Checks

- [x] reporting.fact_current_bc exists
- [x] reporting.fact_movement_bc exists
- [x] reporting.fact_issue_current exists
- [x] reporting.control_current_kpi exists
- [x] reporting.control_movement_kpi exists
- [x] reporting.dim_pic exists
- [x] reporting.dim_bc exists
- [x] reporting.dim_date exists
- [x] Fact_Current_BC grain validated
- [x] Fact_Movement_BC grain validated
- [x] Fact_Issue_Current grain validated
- [x] Dim_PIC unique key validated
- [x] Dim_BC unique key validated
- [x] Dim_Date unique key validated
- [x] PIC orphan keys resolved
- [x] BC orphan keys resolved
- [x] Control_Current_KPI row count validated
- [x] Control_Movement_KPI row count validated
- [x] Current KPI reconciliation validated
- [x] Movement readiness validated as structure-only

### Remaining Checks

- [ ] Power BI tables loaded
- [ ] Power BI relationships created
- [ ] Power BI no fact-to-fact relationship validated
- [ ] Power BI no control relationship validated
- [ ] Power BI no bidirectional filter validated
- [ ] Power BI KPI cards reconciled
- [ ] Movement page guardrail applied
- [ ] User final validation completed
"""

# Append-safe cumulative docs.
append_section_once(DOCS / "progress_log.md", PROGRESS_MARKER, progress_section)
append_section_once(DOCS / "HANDOVER_TO_NEW_CHAT.md", HANDOVER_MARKER, handover_section)

# Append decision/memory docs if they exist, otherwise create.
if (DOCS / "project_memory.md").exists():
    append_section_once(DOCS / "project_memory.md", PROJECT_MEMORY_MARKER, project_memory_section)
else:
    replace_file(DOCS / "project_memory.md", "# Finance_Ops_Dev — Project Memory\n\n" + project_memory_section)

if (DOCS / "decision_log.md").exists():
    append_section_once(DOCS / "decision_log.md", DECISION_MARKER, decision_section)
else:
    replace_file(DOCS / "decision_log.md", "# Finance_Ops_Dev — Decision Log\n\n" + decision_section)

# Replace current_status because it is a latest-state document, not cumulative log.
replace_file(DOCS / "current_status.md", current_status)

# Append checklist update if file exists.
checklist_path = DOCS / "phase_12_powerbi_validation_checklist.md"
if checklist_path.exists():
    append_section_once(
        checklist_path,
        "PHASE_12_SQL_VALIDATION_CHECKLIST_APPEND_2026_05_15",
        validation_checklist_append
    )
else:
    replace_file(checklist_path, "# Phase 12 Power BI Validation Checklist\n\n" + validation_checklist_append)

print()
print("PASS: Phase 12 SQL validation documentation update completed.")
print("Next commands:")
print("  git diff --stat")
print("  git status")
print("  git add 00_docs/progress_log.md 00_docs/HANDOVER_TO_NEW_CHAT.md 00_docs/current_status.md 00_docs/project_memory.md 00_docs/decision_log.md 00_docs/phase_12_powerbi_validation_checklist.md append_phase12_sql_validation_pass_docs.py")
print('  git commit -m "docs: record phase 12 sql validation pass structure"')
print("  git push origin main")
