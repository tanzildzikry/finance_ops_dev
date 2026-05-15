# Handover to New Chat — Finance Ops Dev

## 1. Handover Purpose

This document is used to continue the Finance_Ops_Dev project in a new ChatGPT conversation without losing project context, purpose, progress, structure, rules, validated state, and next actions.

The new assistant must continue from the latest validated project state and must not restart from zero.

---

## 2. Project Identity

Project name:

```text
Finance_Ops_Dev
```

GitHub repository:

```text
https://github.com/tanzildzikry/finance_ops_dev.git
```

Main purpose:

```text
Build a controlled PostgreSQL + Power BI foundation for Finance Ops / Unbilled Monitoring using masked data.
```

Current dashboard focus:

```text
Unbilled Monitoring
Executive Overview
AR Controller
PIC Operation Scoring
Daily Snapshot
Data Quality / Exception Control
```

Current project mode:

```text
FINANCE_OPS_PROJECT MODE
```

Current latest validated phase:

```text
Phase 9.5 — Snapshot Layer Validation
```

Current next phase:

```text
Phase 10 — Approved SQL Examples / KPI SQL Control
```

Current production readiness:

```text
NOT YET
```

Reason:

```text
PostgreSQL raw, clean, and snapshot foundations are validated, but Power BI semantic model, DAX measures, report pages, and Power BI vs SQL reconciliation are not yet complete.
```

---

## 3. Important Operating Rules

The assistant must follow Finance_Ops_Dev rules.

Core project rules:

- RAB = Revenue / planned billable amount.
- High risk = aging > 60 and RAB >= 3,000,000,000.
- UNCLASSIFIED = PIC not input in ERP; correction bucket.
- UNCLASSIFIED is not PIC performance penalty.
- REPORTED = excluded bucket, not active backlog.
- DATELINE KE AR = excluded.
- Source date format = MM/DD/YYYY.
- event_category currently means PIC division.
- event_status = ENDED or ON GOING based on event_end_date vs today.
- Actual cashflow is out of scope until cash-in data exists.

Closed / fully invoiced rule:

```text
bill_status = BILLED
AND invoice_number IS NOT NULL
AND invoice_completion_ratio >= 0.98
```

Preferred open backlog logic:

```text
is_open_unbilled = true
```

Preferred open exposure logic:

```text
open_rab_exposure_amount
```

Do not use simplistic open logic such as:

```text
bill_status <> 'BILLED'
```

Average Aging Open BC rule:

```text
Average Aging Open BC =
AVG(unbilled_aging_days)
WHERE is_open_unbilled = true
AND event_status = 'ENDED'
AND unbilled_aging_days > 0
```

Negative aging and ON GOING events must not be included in Average Aging Open BC.

Daily movement rule:

```text
Daily movement is meaningful only after at least two snapshot dates.
```

Current state:

```text
Daily movement is meaningful because snapshot validation found 2 distinct snapshot dates.
```

---

## 4. Data Safety Policy

Repository uses masked data only.

Allowed in GitHub:

- Masked sample data
- Synthetic sample data
- SQL DDL
- SQL transform
- SQL validation
- Approved SQL examples
- DAX measures
- Power BI documentation
- Semantic model documentation
- Dashboard mapping
- Test scripts
- Reconciliation checklist
- Markdown documentation

Not allowed in GitHub:

- Real CSV
- Real Excel
- Real customer data
- Real PIC data if sensitive
- Real invoice numbers
- Real confidential transaction files
- Database dumps
- `.env`
- Passwords
- Connection strings
- API keys
- Private keys
- PBIX files with embedded real data

Approved masked sample folder:

```text
03_sample_data_masked/
```

Accepted risk:

```text
Amount fields are currently accepted by the user as safe even if not masked.
If repo becomes public or externally shared, amount fields must be reviewed again.
```

---

## 5. Windows / File Creation Operating Rules

Important project execution rule:

```text
Use Python-first file generation for project SQL/MD files.
```

Reason:

```text
PowerShell Set-Content caused UTF-8 BOM / encoding issues in SQL files.
```

Rules:

- Prioritize Python-based file creation instead of PowerShell `Set-Content`.
- Write files using `encoding="utf-8"` without BOM.
- Include BOM check when generating files through Python.
- Use full Windows path.
- Do not use placeholders such as `{target}`, `<USER>`, `PATH/TO/FILE`, or `SQL CONTENT HERE`.
- If path, folder, file name, schema, table, column, or source file name is uncertain, ask user first.
- Do not use Linux/macOS heredoc style such as `python - <<'PY'` in PowerShell.
- Python writer pattern using PowerShell here-string piped to Python is accepted.
- For SQL files using `\copy`, `\echo`, or `\set ON_ERROR_STOP`, run with `psql -f`, not pgAdmin Query Tool.

Known safe project root:

```text
D:\Tanzil\AR COLLECTION\_DASHBOARD POWER BI\Bahan SQL + PBI\finance_ops_dev\Repo Finance_Ops_Dev
```

Known PostgreSQL psql path:

```text
C:\Program Files\PostgreSQL\18\bin\psql.exe
```

---

## 6. Current Repository Structure

Current repo root:

```text
Repo Finance_Ops_Dev/
```

Current important structure:

```text
00_docs/
  .gitkeep
  HANDOVER_TO_NEW_CHAT.md
  progress_log.md
  source_data_preparation.md
  source_file_register.md
  masked_source_review.md
  masked_source_profile_result.md

01_database/
  ddl/
    .gitkeep
    001_create_database_and_schemas.sql
    002_create_and_load_raw_source_tables.sql
  transform/
    003_transform_raw_to_clean.sql
  validation/
    .gitkeep
    001_validate_database_and_schemas.sql
    002_validate_raw_source_load.sql
    003_validate_clean_layer.sql
  snapshot/
    004_create_snapshot_tables.sql
    005_create_snapshot_run_function.sql
    006_execute_first_snapshot.sql
    007_create_latest_snapshot_views.sql
    008_validate_snapshot_layer.sql
  approved_sql_examples/
    .gitkeep

02_powerbi/
  dax/
    .gitkeep
  semantic_model/
    .gitkeep
  page_mapping/
    .gitkeep

03_sample_data_masked/
  README.md
  masked_bc_source_sample.csv
  masked_pic_list_sample.csv

04_python/
  issue_classifier/
    .gitkeep

05_tests/
  sql_tests/
    .gitkeep
  dax_tests/
    .gitkeep
  reconciliation_tests/
    .gitkeep
  source_file_profile_check.py

.env.example
.gitignore
DATA_SAFETY_CHECKLIST.md
README.md
REPO_SCOPE.md
```

---

## 7. Completed Progress Summary

### Phase 0 — Project Safety Foundation

Status:

```text
PASS
```

Completed:

- Repo safety policy created.
- `.gitignore` created.
- `.env.example` created.
- `README.md` created.
- `DATA_SAFETY_CHECKLIST.md` created.
- `REPO_SCOPE.md` created.
- `03_sample_data_masked/README.md` created.
- Real data separated from repo.
- PBIX, database dumps, `.env`, real CSV/Excel blocked from repo.

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 1 — GitHub Repository Setup

Status:

```text
PASS
```

Completed:

- Existing agent-build repo renamed to avoid conflict.
- New GitHub repo connected.
- Local repo pushed to GitHub.
- Repository visibility confirmed public.

GitHub repo:

```text
https://github.com/tanzildzikry/finance_ops_dev.git
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 2 — Repository Structure

Status:

```text
PASS
```

Completed:

- Standard project folders created.
- `.gitkeep` placeholders added.
- Structure pushed to GitHub.

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 3 — PostgreSQL Environment Setup

Status:

```text
PASS
```

Completed:

- PostgreSQL installed.
- PostgreSQL version detected: 18.3.
- PostgreSQL bin path configured.
- Login as `postgres` successful.
- Database created:

```text
finance_ops_dev
```

Schemas created:

```text
raw
clean
snapshot
mart
reporting
documentary
```

SQL files created:

```text
01_database/ddl/001_create_database_and_schemas.sql
01_database/validation/001_validate_database_and_schemas.sql
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 4 — Source / Masked Data Preparation

Status:

```text
PASS
```

Completed:

- `source_data_preparation.md` created.
- `source_file_register.md` created.
- Masked source files added.
- `masked_source_review.md` created.
- Python source profile script created.
- Masked source profile result generated.
- Source files confirmed under approved masked folder.

Masked files:

```text
03_sample_data_masked/masked_bc_source_sample.csv
03_sample_data_masked/masked_pic_list_sample.csv
```

Profile script:

```text
05_tests/source_file_profile_check.py
```

Profile result:

```text
00_docs/masked_source_profile_result.md
```

Source profile result:

```text
masked_bc_source_sample.csv = 8266 rows, 27 headers, duplicate header 0, PASS
masked_pic_list_sample.csv  = 69 rows, 4 headers, duplicate header 0, PASS
```

Important note:

```text
PowerShell source profiling was abandoned because of parsing and encoding issues.
Python source profiling is the accepted approach.
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 5 — Raw Layer Build

Status:

```text
PASS
```

Created file:

```text
01_database/ddl/002_create_and_load_raw_source_tables.sql
```

Completed:

- Created `raw.raw_bc_source`.
- Created `raw.raw_pic_list`.
- Loaded masked BC CSV.
- Loaded masked PIC CSV.
- Used raw-layer text-first approach.
- Added metadata columns:
  - `source_file_name`
  - `loaded_at`
- Fixed psql / PowerShell execution confusion.
- Fixed `\copy` multiline error by writing `\copy` as one full line.
- Added `\set ON_ERROR_STOP on`.

Final raw load result:

```text
raw.raw_bc_source = 8266 rows
raw.raw_pic_list  = 69 rows
```

Key integrity:

```text
raw.raw_bc_source.bc_number | null_or_blank 0 | duplicate 0 | PASS
raw.raw_pic_list.pic_code   | null_or_blank 0 | duplicate 0 | PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 6 — Raw Load Validation Script Separation

Status:

```text
PASS
```

Created file:

```text
01_database/validation/002_validate_raw_source_load.sql
```

Completed:

- Created separate raw validation script.
- Validated raw row count.
- Validated raw key integrity.
- Validated raw metadata.
- Validated raw column count.

Validation:

```text
raw.raw_bc_source | 8266 | 8266 | PASS
raw.raw_pic_list  | 69   | 69   | PASS
raw.raw_bc_source | 29 columns | PASS
raw.raw_pic_list  | 6 columns  | PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 7 — Clean Layer DDL + Raw-to-Clean Transform

Status:

```text
PASS
```

Created file:

```text
01_database/transform/003_transform_raw_to_clean.sql
```

Completed:

- Created / patched `clean.clean_bc`.
- Created / patched `clean.clean_pic_list`.
- Used safe reload approach because existing clean table had dependent views.
- Avoided `DROP TABLE ... CASCADE`.
- Used `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`.
- Used `TRUNCATE` + `INSERT`.
- Parsed dates using MM/DD/YYYY.
- Cast amount fields to numeric.
- Cast aging and closing duration to integer.
- Normalized status fields to uppercase.
- Converted invalid/missing PIC to `UNCLASSIFIED`.
- Preserved metadata:
  - `source_file_name`
  - `loaded_at`
  - `cleaned_at`

Important issue resolved:

```text
DROP TABLE clean.clean_bc was blocked by dependent views.
Decision: avoid DROP CASCADE and use safe reload.
```

Clean row count validation:

```text
clean.clean_bc       = 8266 / 8266 PASS
clean.clean_pic_list = 69 / 69 PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 8 — Clean Layer Validation

Status:

```text
PASS
```

Created file:

```text
01_database/validation/003_validate_clean_layer.sql
```

Completed validation:

- Raw vs clean row count.
- Key integrity.
- Date parsing.
- Amount negative validation.
- UNCLASSIFIED PIC validation.
- PIC orphan validation.
- Billing status validation.
- Event status validation.
- Clean metadata validation.
- Final clean summary.

Important validation outputs:

```text
BC raw vs clean  | 8266 | 8266 | PASS
PIC raw vs clean | 69   | 69   | PASS

clean.clean_bc.bc_number      | null 0 | duplicate 0 | PASS
clean.clean_pic_list.pic_code | null 0 | duplicate 0 | PASS

event_start_date      | parse_failed 0 | PASS
event_end_date        | parse_failed 0 | PASS
latest_invoice_date   | parse_failed 0 | PASS
recording_period_date | parse_failed 0 | PASS

bc_key_integrity      | PASS
negative_amount_check | PASS
pic_key_integrity     | PASS
pic_orphan_check      | PASS
row_count_bc          | PASS
row_count_pic         | PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 9.1 — Create Snapshot Table DDL

Status:

```text
PASS
```

Created file:

```text
01_database/snapshot/004_create_snapshot_tables.sql
```

Created / validated tables:

```text
snapshot.snapshot_run_log
snapshot.bc_daily_status_snapshot
snapshot.bc_daily_issue_history
```

Key columns validated:

```text
snapshot_date
bc_number
is_open_unbilled
open_rab_exposure_amount
is_reported_excluded
invoice_completion_ratio
high_risk_flag
issue_source_text
snapshot_run_id
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 9.2 — Create Snapshot Run Function

Status:

```text
PASS
```

Created file:

```text
01_database/snapshot/005_create_snapshot_run_function.sql
```

Created function:

```sql
snapshot.run_bc_daily_snapshot(
    p_snapshot_date date,
    p_snapshot_cutoff_label text,
    p_source_type text
)
```

Daily snapshot command:

```sql
SELECT snapshot.run_bc_daily_snapshot(CURRENT_DATE, '1600_WIB', 'daily_csv_upload');
```

Important issue resolved:

```text
Existing function with same signature had older parameter names.
PostgreSQL blocked CREATE OR REPLACE FUNCTION.
Resolution: add DROP FUNCTION IF EXISTS snapshot.run_bc_daily_snapshot(date, text, text) before CREATE FUNCTION.
```

Additional issue resolved:

```text
Existing snapshot responsibility constraint blocked responsibility_type = 'EXCLUDED'.
Resolution: use responsibility_type = 'UNKNOWN' for REPORTED_EXCLUDED while retaining detected_issue_category and detected_blocker as REPORTED_EXCLUDED.
```

Function validation:

```text
snapshot.run_bc_daily_snapshot(date,text,text) | PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 9.3 — Execute First Snapshot

Status:

```text
PASS
```

Created file:

```text
01_database/snapshot/006_execute_first_snapshot.sql
```

Executed command:

```sql
SELECT snapshot.run_bc_daily_snapshot(CURRENT_DATE, '1600_WIB', 'daily_csv_upload');
```

Snapshot result:

```text
snapshot_run_id = 3
snapshot_date = 2026-05-15
snapshot_cutoff_label = 1600_WIB
source_type = daily_csv_upload
snapshot_status = COMPLETED
validation_result = PASS
risk_level = LOW
```

Row count validation:

```text
total_clean_bc_rows        = 8266
total_snapshot_rows        = 8266
total_issue_history_rows   = 8266

snapshot.bc_daily_status_snapshot | 8266 / 8266 | PASS
snapshot.bc_daily_issue_history   | 8266 / 8266 | PASS
```

Latest snapshot of day validation:

```text
snapshot_date = 2026-05-15
latest_snapshot_rows = 8266
latest_flag_true_count = 8266
PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 9.4 — Create Latest Snapshot Views

Status:

```text
PASS
```

Created file:

```text
01_database/snapshot/007_create_latest_snapshot_views.sql
```

Created views:

```text
snapshot.vw_latest_snapshot_run
snapshot.vw_latest_bc_daily_status_snapshot
snapshot.vw_latest_bc_daily_issue_history
snapshot.vw_latest_snapshot_kpi_control
```

Important issue resolved:

```text
Existing snapshot tables did not contain snapshot_row_id / issue_history_id expected by first view version.
Resolution: remove those columns from latest views for compatibility with existing table structure.
```

View validation:

```text
snapshot.vw_latest_bc_daily_issue_history   | PASS
snapshot.vw_latest_bc_daily_status_snapshot | PASS
snapshot.vw_latest_snapshot_kpi_control     | PASS
snapshot.vw_latest_snapshot_run             | PASS
```

Row count validation:

```text
snapshot.vw_latest_bc_daily_issue_history   | 8266 / 8266 | PASS
snapshot.vw_latest_bc_daily_status_snapshot | 8266 / 8266 | PASS
```

KPI control preview after patch:

```text
snapshot_run_id                   = 3
snapshot_date                     = 2026-05-15
total_bc_count                    = 8266
open_bc_count                     = 8145
open_rab_exposure_amount          = 4,956,993,250,804.46
high_risk_bc_count                = 3
high_risk_rab_exposure_amount     = 23,820,974,461.00
reported_excluded_bc_count        = 112
unclassified_pic_count            = 12
manual_review_bc_count            = 20
average_aging_open_bc             = 51.0055248618784530
```

Important KPI logic patch:

```text
average_aging_open_bc originally included negative aging / ON GOING events.
Revised rule:
is_open_unbilled = true
AND event_status = 'ENDED'
AND unbilled_aging_days > 0
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

### Phase 9.5 — Snapshot Layer Validation

Status:

```text
PASS
```

Created file:

```text
01_database/snapshot/008_validate_snapshot_layer.sql
```

Completed validation:

- Latest snapshot run log validation.
- Latest snapshot row count validation.
- Snapshot key integrity validation.
- Required control field null validation.
- REPORTED exclusion validation.
- Open exposure validation.
- High risk validation.
- UNCLASSIFIED validation.
- Average aging logic validation.
- KPI control view validation.
- Snapshot issue history validation.
- Daily movement readiness validation.
- Final snapshot validation summary.

Important outputs:

```text
KPI control view validation | PASS

snapshot_run_id = 3
snapshot_date = 2026-05-15
total_bc_count = 8266
open_bc_count = 8145
open_rab_exposure_amount = 4,956,993,250,804.46
high_risk_bc_count = 3
high_risk_rab_exposure_amount = 23,820,974,461.00
reported_excluded_bc_count = 112
unclassified_pic_count = 12
manual_review_bc_count = 20
average_aging_open_bc = 51.0055248618784530
```

Issue history validation:

```text
issue_history_row_count = 8266
blank_issue_source_text_count = 0
null_detected_issue_category_count = 0
null_detected_blocker_count = 0
PASS
```

Daily movement readiness:

```text
distinct_snapshot_dates = 2
validation_result = PASS
control_note = Daily movement is meaningful.
```

Final snapshot validation summary:

```text
average_aging_logic          | PASS
high_risk_logic              | PASS
latest_issue_view_row_count  | PASS
latest_status_view_row_count | PASS
reported_excluded_not_open   | PASS
```

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

---

## 8. Current PostgreSQL State

PostgreSQL database:

```text
finance_ops_dev
```

Current schemas:

| Schema | Purpose |
|---|---|
| raw | Raw ingest layer. Stores source data with minimal transformation. |
| clean | Clean layer. Stores standardized, typed, and validated data. |
| snapshot | Snapshot layer. Stores daily BC status snapshot and issue history. |
| mart | Subject-area analytical tables. |
| reporting | Power BI-ready views and reporting outputs. |
| documentary | Data dictionary, validation logs, lineage, and documentation metadata. |

Current raw tables:

```text
raw.raw_bc_source
raw.raw_pic_list
```

Current clean tables:

```text
clean.clean_bc
clean.clean_pic_list
```

Current snapshot tables:

```text
snapshot.snapshot_run_log
snapshot.bc_daily_status_snapshot
snapshot.bc_daily_issue_history
```

Current latest snapshot views:

```text
snapshot.vw_latest_snapshot_run
snapshot.vw_latest_bc_daily_status_snapshot
snapshot.vw_latest_bc_daily_issue_history
snapshot.vw_latest_snapshot_kpi_control
```

Current confirmed row counts:

```text
raw.raw_bc_source                              = 8266
raw.raw_pic_list                               = 69
clean.clean_bc                                 = 8266
clean.clean_pic_list                           = 69
snapshot.vw_latest_bc_daily_status_snapshot    = 8266
snapshot.vw_latest_bc_daily_issue_history      = 8266
```

Latest snapshot run:

```text
snapshot_run_id = 3
snapshot_date = 2026-05-15
snapshot_status = COMPLETED
validation_result = PASS
risk_level = LOW
```

---

## 9. Current Git State

Expected Git state at handover point:

```bash
git status
```

Expected result:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

If not clean, review untracked/modified files before continuing.

Temporary helper files such as `write_phase*_validation.py` must not be committed unless explicitly promoted as official project source code.

---

## 10. Current Hold Point

Current hold point:

```text
After Phase 9.5 — Snapshot Layer Validation
```

Latest validation result:

```text
PASS
```

Risk level:

```text
LOW
```

Next recommended phase:

```text
Phase 10 — Approved SQL Examples / KPI SQL Control
```

---

## 11. Immediate Next Steps

### Step 1 — Confirm progress_log.md update

Confirm whether `00_docs/progress_log.md` has been updated through Phase 9.5 and committed.

Expected commit message:

```text
docs: update progress log through snapshot validation
```

If not yet updated, update progress log before Phase 10.

### Step 2 — Start Phase 10

Phase 10 target:

```text
Approved SQL Examples / KPI SQL Control
```

Main tasks:

- Create approved SQL examples file if not already created in current repo structure.
- Add Executive Overview KPI SQL.
- Add latest snapshot KPI control SQL.
- Add AR Controller aging SQL.
- Add Top High Risk BC SQL.
- Add PIC Operation Scoring base SQL.
- Add BC investigation SQL.
- Add Data Quality / Exception SQL.
- Validate each SQL against latest snapshot views.
- Avoid `SELECT *`.
- Use explicit `schema.table`.
- Use `snapshot.vw_latest_bc_daily_status_snapshot` for latest dashboard KPI.
- Use `snapshot.vw_latest_snapshot_kpi_control` for reconciliation baseline.
- Use `is_open_unbilled` and `open_rab_exposure_amount`.
- Exclude REPORTED from active backlog.
- Do not create actual cashflow logic.

Recommended file:

```text
01_database/approved_sql_examples/009_approved_kpi_sql_examples.sql
```

### Step 3 — Continue to Power BI after SQL controls

Do not start Power BI semantic model until SQL KPI controls are validated.

---

## 12. Recommended Files to Upload in New Chat

In the new chat, upload these files first if GitHub access is unavailable:

### Must upload

```text
00_docs/HANDOVER_TO_NEW_CHAT.md
00_docs/progress_log.md
01_database/ddl/001_create_database_and_schemas.sql
01_database/ddl/002_create_and_load_raw_source_tables.sql
01_database/transform/003_transform_raw_to_clean.sql
01_database/validation/001_validate_database_and_schemas.sql
01_database/validation/002_validate_raw_source_load.sql
01_database/validation/003_validate_clean_layer.sql
01_database/snapshot/004_create_snapshot_tables.sql
01_database/snapshot/005_create_snapshot_run_function.sql
01_database/snapshot/006_execute_first_snapshot.sql
01_database/snapshot/007_create_latest_snapshot_views.sql
01_database/snapshot/008_validate_snapshot_layer.sql
```

### Useful supporting docs

```text
00_docs/masked_source_profile_result.md
00_docs/masked_source_review.md
README.md
REPO_SCOPE.md
DATA_SAFETY_CHECKLIST.md
```

### Also provide GitHub repo link

```text
https://github.com/tanzildzikry/finance_ops_dev.git
```

Important:

```text
If ChatGPT in the new chat cannot access GitHub directly, upload the files manually.
```

---

## 13. Suggested Opening Prompt for New Chat

Use this prompt in the new chat:

```text
Saya ingin melanjutkan project Finance_Ops_Dev dari handover ini.

Project mode: FINANCE_OPS_PROJECT MODE.
GitHub repo: https://github.com/tanzildzikry/finance_ops_dev.git

Current status:
- Phase 0 Repo Safety Foundation = PASS
- Phase 1 GitHub Setup = PASS
- Phase 2 Repository Structure = PASS
- Phase 3 PostgreSQL Environment Setup = PASS
- Phase 4 Source / Masked Data Preparation = PASS
- Phase 5 Raw Layer Build = PASS
- Phase 6 Raw Load Validation = PASS
- Phase 7 Clean Layer Transform = PASS
- Phase 8 Clean Layer Validation = PASS
- Phase 9.1 Snapshot Table DDL = PASS
- Phase 9.2 Snapshot Run Function = PASS
- Phase 9.3 First Snapshot Execution = PASS
- Phase 9.4 Latest Snapshot Views = PASS
- Phase 9.5 Snapshot Layer Validation = PASS

Latest snapshot:
- snapshot_run_id = 3
- snapshot_date = 2026-05-15
- latest snapshot rows = 8266
- issue history rows = 8266
- validation_result = PASS
- risk_level = LOW

Current hold point:
After Phase 9.5 Snapshot Layer Validation.

Next phase:
Phase 10 — Approved SQL Examples / KPI SQL Control.

Please continue using Finance_Ops_Dev business rules:
- RAB = Revenue / planned billable amount
- High risk = aging > 60 and RAB >= 3,000,000,000
- UNCLASSIFIED = correction bucket, not PIC penalty
- REPORTED = excluded from active backlog
- Source date format = MM/DD/YYYY
- Actual cashflow is out of scope until cash-in data exists
- Use is_open_unbilled for open backlog
- Use open_rab_exposure_amount for open exposure
- Average Aging Open BC only counts is_open_unbilled = true, event_status = ENDED, and unbilled_aging_days > 0

Please do not restart from zero.
Please first read the handover and progress log, then summarize current state, validation status, risk, and next action.
```

---

## 14. Validation Philosophy for New Chat

The assistant must continue with this output style:

```text
KONDISI —
PENYEBAB —
KONTROL —
AKSI —
VALIDATION RESULT —
```

Validation results allowed:

```text
PASS
NEEDS REVIEW
NEEDS REVISION
BLOCKED
```

Risk levels:

```text
LOW
MEDIUM
HIGH
CRITICAL
```

---

## 15. Critical Warnings for Continuation

Do not claim production-ready yet.

Production readiness is still:

```text
NOT YET
```

Reasons:

- Power BI has not yet been connected.
- Power BI semantic model has not yet been validated.
- DAX measures have not yet been created/tested in actual PBIX.
- Power BI vs SQL reconciliation has not yet been performed.
- Refresh readiness and deployment controls are not complete.
- User final validation is not yet complete.

Do not create actual cashflow / cash-in / DSO / collection performance logic yet.

Reason:

```text
Cash-in / cash receipt data does not exist in current scope.
```

---

## 16. Known Issues Resolved

### Issue 1 — SQL pasted directly into PowerShell

Status:

```text
RESOLVED
```

Resolution:

```text
Save SQL as .sql and run through psql -f.
```

---

### Issue 2 — psql \copy multiline parse error

Status:

```text
RESOLVED
```

Resolution:

```text
Write \copy as one full psql meta-command line.
```

---

### Issue 3 — UTF-8 BOM error in SQL file

Status:

```text
RESOLVED
```

Error example:

```text
ERROR: syntax error at or near "ï»¿"
```

Resolution:

```text
Use Python writer with encoding="utf-8" and BOM check.
```

---

### Issue 4 — Existing clean table blocked DROP

Status:

```text
RESOLVED
```

Resolution:

```text
Avoid DROP ... CASCADE. Use ALTER TABLE ADD COLUMN IF NOT EXISTS + TRUNCATE + INSERT.
```

---

### Issue 5 — Snapshot function parameter name conflict

Status:

```text
RESOLVED
```

Resolution:

```text
DROP FUNCTION IF EXISTS snapshot.run_bc_daily_snapshot(date, text, text) before CREATE FUNCTION.
```

---

### Issue 6 — Snapshot responsibility constraint blocked EXCLUDED

Status:

```text
RESOLVED
```

Resolution:

```text
Use responsibility_type = UNKNOWN for REPORTED_EXCLUDED while preserving detected_issue_category and detected_blocker as REPORTED_EXCLUDED.
```

---

### Issue 7 — Latest snapshot view assumed missing ID columns

Status:

```text
RESOLVED
```

Resolution:

```text
Do not select snapshot_row_id or issue_history_id in latest views because existing tables may not contain those columns.
```

---

### Issue 8 — Average Aging Open BC included negative / ON GOING rows

Status:

```text
RESOLVED
```

Resolution:

```text
Average Aging Open BC now filters:
is_open_unbilled = true
AND event_status = 'ENDED'
AND unbilled_aging_days > 0
```

---

## 17. Next Phase Planning

### Phase 10 — Approved SQL Examples / KPI SQL Control

Status:

```text
NOT STARTED
```

Planned tasks:

- [ ] Create approved KPI SQL examples file.
- [ ] Add Executive Overview KPI SQL.
- [ ] Add KPI control SQL using `snapshot.vw_latest_snapshot_kpi_control`.
- [ ] Add AR Controller aging bucket SQL.
- [ ] Add Top High Risk BC SQL.
- [ ] Add PIC Operation Scoring base SQL.
- [ ] Add BC investigation SQL.
- [ ] Add Data Quality / Exception SQL.
- [ ] Validate SQL results in PostgreSQL.
- [ ] Commit approved SQL examples.
- [ ] Update progress log.

Recommended file:

```text
01_database/approved_sql_examples/009_approved_kpi_sql_examples.sql
```

Validation result:

```text
NOT STARTED
```

Risk level before control:

```text
MEDIUM
```

---

### Phase 11 — Power BI Connection

Status:

```text
NOT STARTED
```

Planned tasks:

- [ ] Open Power BI Desktop.
- [ ] Connect to PostgreSQL.
- [ ] Use Import Mode for first build.
- [ ] Load latest snapshot view.
- [ ] Load issue history view if needed.
- [ ] Load PIC dimension from clean layer.
- [ ] Create/load date dimension.
- [ ] Confirm PBIX with embedded real data is not committed.

---

### Phase 12 — Power BI Semantic Model

Status:

```text
NOT STARTED
```

Planned tasks:

- [ ] Define fact and dimension tables.
- [ ] Create relationships.
- [ ] Avoid many-to-many unless explicitly justified.
- [ ] Set single-direction filtering.
- [ ] Hide technical columns.
- [ ] Validate cardinality and filter direction.

---

### Phase 13 — DAX Measure Build

Status:

```text
NOT STARTED
```

Planned tasks:

- [ ] Create measure table.
- [ ] Use snapshot fields.
- [ ] Use `open_rab_exposure_amount`.
- [ ] Use `is_open_unbilled`.
- [ ] Use Average Aging Open BC rule.
- [ ] Avoid recreating complex SQL logic in DAX.

---

### Phase 14 — Power BI vs SQL Reconciliation

Status:

```text
NOT STARTED
```

Planned tasks:

- [ ] Reconcile Power BI cards to approved SQL.
- [ ] Reconcile open BC count.
- [ ] Reconcile open RAB exposure.
- [ ] Reconcile high risk BC count.
- [ ] Reconcile high risk RAB exposure.
- [ ] Reconcile REPORTED excluded count.
- [ ] Reconcile UNCLASSIFIED count.
- [ ] Reconcile average aging.

---

## 18. Handover Validation Result

Validation result:

```text
PASS
```

Risk level:

```text
LOW
```

Reason:

```text
Project purpose, repo structure, active business rules, PostgreSQL raw-clean-snapshot state, completed phases through Phase 9.5, known issues, current hold point, next actions, and continuation rules are documented.
```

---

## Phase 12 Handover Update — Semantic Model Refactor

Marker: PHASE_12_HANDOVER_APPEND_2026_05_15

Updated: 2026-05-15

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

---

## Phase 12 Handover Update — SQL Validation Result

Marker: PHASE_12_SQL_VALIDATION_HANDOVER_APPEND_2026_05_15

Updated: 2026-05-15

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
