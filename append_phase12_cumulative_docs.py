from pathlib import Path
from datetime import date
import sys

ROOT = Path.cwd()
DOCS = ROOT / "00_docs"

TODAY = date.today().isoformat()

PROGRESS_MARKER = "PHASE_12_SEMANTIC_MODEL_REFACTOR_APPEND_2026_05_15"
HANDOVER_MARKER = "PHASE_12_HANDOVER_APPEND_2026_05_15"

PROGRESS_FILE = DOCS / "progress_log.md"
HANDOVER_FILE = DOCS / "HANDOVER_TO_NEW_CHAT.md"

def read_text_utf8(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Required file not found: {path}")
    return path.read_text(encoding="utf-8")

def write_text_utf8_no_bom(path: Path, content: str) -> None:
    path.write_text(content.rstrip() + "\n", encoding="utf-8")

def append_section_once(path: Path, marker: str, section: str) -> None:
    original = read_text_utf8(path)

    if marker in original:
        print(f"SKIP: marker already exists in {path}")
        return

    before_lines = len(original.splitlines())
    new_content = original.rstrip() + "\n\n" + section.strip() + "\n"
    after_lines = len(new_content.splitlines())

    if after_lines <= before_lines:
        raise RuntimeError(
            f"BLOCKED: append did not increase line count for {path}. "
            f"Before={before_lines}, After={after_lines}"
        )

    # Extra guardrail for cumulative files:
    # this script must append only, never replace existing content.
    if not new_content.startswith(original.rstrip()):
        raise RuntimeError(
            f"BLOCKED: new content does not preserve existing file prefix for {path}"
        )

    write_text_utf8_no_bom(path, new_content)
    print(f"PASS: appended section to {path}")
    print(f"Line count: {before_lines} -> {after_lines}")

progress_section = f"""
---

## Phase 12 — Power BI Semantic Model Refactor / Relationship Setup

Marker: {PROGRESS_MARKER}

Status: IN PROGRESS  
Validation Result: NEEDS REVIEW  
Risk Level: LOW  
Updated: {TODAY}

### Summary

Phase 12 semantic model refactor has been approved as the current design baseline.

The model will use curated reporting views only for Power BI exposure. Backend raw, clean, snapshot base, and issue history base tables remain part of the database pipeline and audit trail, but should not be loaded into the main PBIX model.

### Approved Power BI Model

- Dim_Date
- Dim_PIC
- Dim_BC
- Fact_Current_BC
- Fact_Movement_BC
- Fact_Issue_Current
- Control_Current_KPI
- Control_Movement_KPI
- _Measures

### Approved Source Rules

- Current dashboard fact:
  - snapshot.vw_latest_bc_daily_status_snapshot
- KPI reconciliation:
  - snapshot.vw_latest_snapshot_kpi_control
- Movement / trend fact:
  - snapshot.vw_daily_status_snapshot_latest_per_day
- Movement KPI control:
  - snapshot.vw_daily_kpi_control_latest_per_day

### Relationship Rules

- Use 1:* single-direction relationships from dimensions to facts.
- Do not create active fact-to-fact relationships.
- Do not relate control tables to facts.
- Do not use bidirectional filters.
- Do not use uncontrolled many-to-many relationships.
- Use Dim_BC for BC-level drill-through and issue detail.
- Keep Dim_Date active to movement fact only.
- Avoid active Dim_Date relationship to latest/current fact.

### DAX Refactor Rules

- Use canonical measures only.
- Use prefixes:
  - Current
  - Control
  - Recon
  - Movement
- Do not create by-PIC, by-Customer, or by-Division measures.
- Dimension breakdown must come from relationship filter context.
- Use is_open_unbilled for open backlog.
- Use open_rab_exposure_amount for open exposure.
- Do not use billing_status <> 'BILLED' as open logic.
- Do not create actual cashflow, DSO, payment overdue final, or collection performance measures.

### Movement Readiness Rule

Movement source is structurally safe.

Movement trend must not be interpreted until:

```text
latest-per-day distinct_snapshot_dates >= 2
```

Current note:
- latest-per-day distinct_snapshot_dates = 1
- movement page may be built structurally
- movement insight must remain disabled / guarded

### Documentation Added

- 00_docs/phase_12_semantic_model_blueprint.md
- 00_docs/phase_12_relationship_matrix.md
- 00_docs/phase_12_powerbi_validation_checklist.md
- 00_docs/phase_12_measure_refactor_notes.md
- 00_docs/current_status.md
- 00_docs/project_memory.md
- 00_docs/decision_log.md

### Next Actions

1. Create reporting schema curated views.
2. Create SQL validation script for Phase 12.
3. Load curated views into Power BI.
4. Apply relationship matrix.
5. Create canonical DAX measures.
6. Validate KPI cards against Control_Current_KPI.
7. Validate no fact-to-fact, no control relationships, no bidirectional relationships.
8. Update status after PBIX validation.
"""

handover_section = f"""
---

## Phase 12 Handover Update — Semantic Model Refactor

Marker: {HANDOVER_MARKER}

Updated: {TODAY}

### Current Phase

Phase 12 — Power BI Semantic Model Build / Relationship Setup

Status:
- IN PROGRESS
- NEEDS REVIEW
- Risk Level: LOW

### Critical Continuity Rules

- Use Finance_Ops_Project Mode.
- progress_log.md must remain cumulative from Phase 0.
- Do not overwrite cumulative documentation files.
- Documentation and repo updates should be terminal-first / script-first.
- Use Python-first file generation.
- Use UTF-8 without BOM.
- For cumulative files, use append-safe patching with marker checks.
- If a script reduces line count of progress_log.md or HANDOVER_TO_NEW_CHAT.md, the patch is BLOCKED.

### Phase 12 Approved Model

Power BI should use:

- Dim_Date
- Dim_PIC
- Dim_BC
- Fact_Current_BC
- Fact_Movement_BC
- Fact_Issue_Current
- Control_Current_KPI
- Control_Movement_KPI
- _Measures

### Phase 12 Relationship Rules

- Dimension to fact only.
- Cardinality 1:*.
- Filter direction Single.
- No active fact-to-fact relationship.
- No relationship from control tables to facts.
- No bidirectional filter.
- No uncontrolled many-to-many relationship.
- Dim_Date active only to Fact_Movement_BC.
- Avoid active Dim_Date to Fact_Current_BC.

### Phase 12 DAX Rules

- Canonical measures only.
- Prefixes:
  - Current
  - Control
  - Recon
  - Movement
- No by-PIC / by-Customer / by-Division measures.
- No duplicate synonym measures.
- Use is_open_unbilled and open_rab_exposure_amount.
- Do not use billing_status <> 'BILLED' as open backlog logic.
- Do not create cashflow actual, DSO, collection performance, or payment overdue final measures.

### Movement Rule

Movement trend is not meaningful until latest-per-day distinct_snapshot_dates >= 2.

Current condition:
- distinct_snapshot_dates = 1
- movement source is structurally safe
- movement trend insight must not be interpreted yet

### Next Step

Proceed to create Phase 12 reporting SQL views and validation script.
"""

def main() -> int:
    print("Finance_Ops_Dev Phase 12 cumulative documentation append patch")
    print(f"Root: {ROOT}")

    if not DOCS.exists():
        print(f"ERROR: 00_docs folder not found at {DOCS}")
        return 1

    append_section_once(PROGRESS_FILE, PROGRESS_MARKER, progress_section)
    append_section_once(HANDOVER_FILE, HANDOVER_MARKER, handover_section)

    print("PASS: append-safe cumulative documentation patch completed.")
    print("Next commands:")
    print("  git diff --stat")
    print("  git diff -- 00_docs/progress_log.md")
    print("  git diff -- 00_docs/HANDOVER_TO_NEW_CHAT.md")
    print("  git status")
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
