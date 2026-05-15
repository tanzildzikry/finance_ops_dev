# Progress Log — Finance Ops Dev

## Current Status

Project: Finance_Ops_Dev
Repository: finance_ops_dev
GitHub Repository: https://github.com/tanzildzikry/finance_ops_dev.git
Current Phase: Phase 11 — Power BI Connection / Semantic Model Preparation
Current Hold Point: Phase 11 completed; Power BI source readiness validated and ready for semantic model build
Last Updated: 2026-05-15

Current validation result: PASS up to Phase 11
Current risk level after control: LOW
Production readiness: NOT YET

---

## Project Scope

Current dashboard focus:

- Unbilled Monitoring
- Executive Overview
- AR Controller
- PIC Operation Scoring
- Daily Snapshot
- Data Quality / Exception Control

Current in-scope technical foundation:

- PostgreSQL database foundation
- Raw source ingestion
- Clean layer transform
- Snapshot layer
- Snapshot latest views
- Snapshot KPI control
- SQL validation
- Power BI semantic model preparation
- DAX measure preparation
- Reconciliation between SQL and Power BI

Out of scope for current dashboard:

- Actual cashflow
- Actual cash-in
- DSO
- Collection performance
- Payment overdue final

Cashflow will be handled later only after cash-in / cash receipt data exists.

---

## Active Business Rules

- RAB = Revenue / planned billable amount.
- High risk = aging > 60 and RAB >= 3,000,000,000.
- UNCLASSIFIED = PIC not input in ERP; correction bucket.
- UNCLASSIFIED is not a PIC performance penalty.
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

Preferred open backlog logic when snapshot v1.1 exists:

```text
is_open_unbilled = true
```

Preferred open exposure logic when snapshot v1.1 exists:

```text
open_rab_exposure_amount
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

---

## Repository Safety Rules

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

Control note:

```text
Amount fields are currently accepted by the user as safe, but must be reviewed again if the repository is shared externally or if repo visibility changes.
```

---

## Current Repository Structure

```text
00_docs/
  progress_log.md
  source_data_preparation.md
  source_file_register.md
  masked_source_review.md
  masked_source_profile_result.md

01_database/
  ddl/
    001_create_database_and_schemas.sql
    002_create_and_load_raw_source_tables.sql
  transform/
    003_transform_raw_to_clean.sql
  validation/
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

02_powerbi/
  dax/
  semantic_model/
  page_mapping/

03_sample_data_masked/
  README.md
  masked_bc_source_sample.csv
  masked_pic_list_sample.csv

04_python/
  issue_classifier/

05_tests/
  sql_tests/
  dax_tests/
  reconciliation_tests/
  source_file_profile_check.py

.env.example
.gitignore
DATA_SAFETY_CHECKLIST.md
README.md
REPO_SCOPE.md
```

---

# Phase 0 — Project Safety Foundation

Status: PASS

Completed items:

- Repository will be private first.
- No real data is stored in the repository.
- Masked sample data is allowed.
- Masked sample column mapping is identical to the real project.
- Real project data remains in PostgreSQL or secure local folder.
- Repository folder is separated from real data folder.
- `.gitignore` created.
- `.env.example` created.
- Root `README.md` created.
- `DATA_SAFETY_CHECKLIST.md` created.
- `REPO_SCOPE.md` created.
- `03_sample_data_masked/README.md` created.
- Real PBIX files are blocked from repository.
- Real CSV / Excel files are blocked from repository.
- Database dumps are blocked from repository.
- Credentials and `.env` files are blocked from repository.

Committed files:

- `.gitignore`
- `.env.example`
- `README.md`
- `DATA_SAFETY_CHECKLIST.md`
- `REPO_SCOPE.md`
- `03_sample_data_masked/README.md`

Commit message:

```text
chore: initialize repo safety foundation
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 1 — GitHub Repository Setup

Status: PASS

Completed items:

- Existing agent-build repository renamed to avoid naming conflict.
- New GitHub repository connected for Finance Ops Dev project.
- Local repository connected to GitHub remote.
- Initial commit pushed to GitHub.
- Repository visibility confirmed public after user updated visibility.

GitHub repository:

```text
https://github.com/tanzildzikry/finance_ops_dev.git
```

Remote validation:

```text
origin  https://github.com/tanzildzikry/finance_ops_dev.git (fetch)
origin  https://github.com/tanzildzikry/finance_ops_dev.git (push)
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 2 — Repository Structure

Status: PASS

Created folder structure:

```text
00_docs/
01_database/
  ddl/
  transform/
  validation/
  snapshot/
  approved_sql_examples/
02_powerbi/
  dax/
  semantic_model/
  page_mapping/
03_sample_data_masked/
04_python/
  issue_classifier/
05_tests/
  sql_tests/
  dax_tests/
  reconciliation_tests/
```

Placeholder `.gitkeep` files created for empty folders.

Commit message:

```text
chore: add project folder structure
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 3 — PostgreSQL Environment Setup

Status: PASS

## Phase 3.1 — PostgreSQL Installation Check

Status: PASS

Findings:

- PostgreSQL is installed.
- PostgreSQL version detected: PostgreSQL 18.3.
- `psql.exe` exists in:

```text
C:\Program Files\PostgreSQL\18\bin
```

Initial issue:

```text
psql : The term 'psql' is not recognized
```

Cause:

```text
PostgreSQL bin folder was not yet added to Windows PATH.
```

Resolution:

```text
C:\Program Files\PostgreSQL\18\bin
```

was added to user PATH.

Validation result: PASS
Risk level after control: LOW

---

## Phase 3.2 — PostgreSQL Login Test

Status: PASS

Login command:

```bash
psql -U postgres
```

Validation result:

```text
postgres=#
```

Meaning:

```text
Login as PostgreSQL superuser postgres was successful.
```

Control note:

```text
Windows console code page warning appeared but does not block database setup.
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 3.3 — Database and Schema Setup Script

Status: PASS

Created SQL file:

```text
01_database/ddl/001_create_database_and_schemas.sql
```

Purpose:

- Create project database.
- Create controlled schemas.
- Prepare PostgreSQL foundation for raw, clean, snapshot, mart, reporting, and documentary layers.

Commit message:

```text
feat: add database and schema setup script
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 3.4 — Database and Schema Execution

Status: PASS

Database created:

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

Validation SQL:

```sql
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN (
    'raw',
    'clean',
    'snapshot',
    'mart',
    'reporting',
    'documentary'
)
ORDER BY schema_name;
```

Validation result:

```text
schema_name
-----------
clean
documentary
mart
raw
reporting
snapshot

(6 rows)
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 3.5 — Database Setup Validation Script

Status: PASS

Created validation SQL file:

```text
01_database/validation/001_validate_database_and_schemas.sql
```

Validation purpose:

- Confirm current database.
- Validate required schema existence.
- Validate required schema count.
- Produce final Phase 3 database foundation validation result.

Expected database:

```text
finance_ops_dev
```

Expected schemas:

```text
raw
clean
snapshot
mart
reporting
documentary
```

Final validation result:

```text
PASS
```

Commit message:

```text
test: add database and schema validation script
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 4 — Source / Masked Data Preparation

Status: PASS

Completed items:

- `source_data_preparation.md` created.
- `source_file_register.md` created.
- Masked source files added.
- `masked_source_review.md` created.
- Python source profile script created.
- Masked source profile result generated.
- Source files confirmed under approved masked folder.
- File profile checked:
  - file existence
  - file size
  - delimiter
  - header count
  - row count
  - duplicate header count
  - header list

Masked files added:

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

| Source File | Row Count | Header Count | Duplicate Header Count | Validation Result | Risk Level |
|---|---:|---:|---:|---|---|
| masked_bc_source_sample.csv | 8266 | 27 | 0 | PASS | LOW |
| masked_pic_list_sample.csv | 69 | 4 | 0 | PASS | LOW |

BC source expected headers:

```text
NO
EVENT NAME
CUSTOMER
EVENT START DATE
EVENT END DATE
UNBILL AGING
EVENT STATUS
EVENT CATEGORY
PIC INTERNAL
BC NUMBER
NILAI
RAB
TOTAL TERINVOICE
UMK RELEASED
UMK ISSUED
PERIODE PENCATATAN
REMARKS
DOKUMEN KURANG
DATELINE KE AR
PIC USER
PO STATUS
UMK STATUS
BILL STATUS
INVOICE NUMBER
INVOICE DATE (LATEST)
CLOSING DURATION
HANDLING FEE
```

PIC source expected headers:

```text
Nama Lengkap
PIC
DIVISI
STATUS
```

Important note:

```text
PowerShell script was abandoned for source profiling because of parsing and encoding issues.
Python script is now the accepted approach for source profile checking.
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 5 — Raw Layer Build

Status: PASS

Completed items:

- Created raw source table load script.
- Created `raw.raw_bc_source`.
- Created `raw.raw_pic_list`.
- Used raw layer text-first approach.
- Loaded masked BC CSV into PostgreSQL raw table.
- Loaded masked PIC CSV into PostgreSQL raw table.
- Added source metadata columns:
  - `source_file_name`
  - `loaded_at`
- Debugged psql / PowerShell execution issue.
- Debugged `\copy` multiline issue.
- Finalized `\copy` as one-line psql meta-command.
- Added `\set ON_ERROR_STOP on` to stop script on load error.

Created file:

```text
01_database/ddl/002_create_and_load_raw_source_tables.sql
```

Active source paths:

```text
D:/Tanzil/AR COLLECTION/_DASHBOARD POWER BI/Bahan SQL + PBI/finance_ops_dev/Repo Finance_Ops_Dev/03_sample_data_masked/masked_bc_source_sample.csv
```

```text
D:/Tanzil/AR COLLECTION/_DASHBOARD POWER BI/Bahan SQL + PBI/finance_ops_dev/Repo Finance_Ops_Dev/03_sample_data_masked/masked_pic_list_sample.csv
```

Final raw load result:

```text
raw.raw_bc_source = 8266 rows
raw.raw_pic_list  = 69 rows
```

Key integrity result:

```text
raw.raw_bc_source.bc_number | table_row_count 8266 | null_or_blank_count 0 | duplicate_count 0 | PASS
raw.raw_pic_list.pic_code   | table_row_count 69   | null_or_blank_count 0 | duplicate_count 0 | PASS
```

Metadata validation result:

```text
masked_bc_source_sample.csv | row_count 8266
masked_pic_list_sample.csv  | row_count 69
```

Issues resolved:

1. SQL script was initially pasted directly into PowerShell.
   - Result: PowerShell parse error on SQL comments.
   - Resolution: save SQL script as `.sql` file and run through `psql`.

2. `\copy` was initially written as multiline.
   - Result: `\copy: parse error at end of line`.
   - Resolution: write each `\copy` command as one full line.

3. Existing raw tables from previous attempt caused metadata mismatch.
   - Resolution: controlled reload with `DROP TABLE IF EXISTS` for raw tables in local development script.

Commit message:

```text
feat: add raw source table load script
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 6 — Raw Load Validation Script Separation

Status: PASS

Completed items:

- Created separate validation script for raw load.
- Validation can now be rerun without recreate/drop/load.
- Validated raw row count.
- Validated raw key integrity.
- Validated raw metadata.
- Validated raw column count.

Created file:

```text
01_database/validation/002_validate_raw_source_load.sql
```

Row count validation:

```text
raw.raw_bc_source | actual_row_count 8266 | expected_row_count 8266 | PASS
raw.raw_pic_list  | actual_row_count 69   | expected_row_count 69   | PASS
```

Key integrity validation:

```text
raw.raw_bc_source.bc_number | table_row_count 8266 | null_or_blank_count 0 | duplicate_count 0 | PASS
raw.raw_pic_list.pic_code   | table_row_count 69   | null_or_blank_count 0 | duplicate_count 0 | PASS
```

Metadata validation:

```text
masked_bc_source_sample.csv | row_count 8266
masked_pic_list_sample.csv  | row_count 69
```

Header / column count validation:

```text
raw.raw_bc_source | actual_column_count 29 | expected_column_count 29 | PASS
raw.raw_pic_list  | actual_column_count 6  | expected_column_count 6  | PASS
```

Column count note:

```text
Raw source BC has 27 source columns + 2 metadata columns = 29 columns.
Raw source PIC has 4 source columns + 2 metadata columns = 6 columns.
```

Commit message:

```text
test: add raw source load validation
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 7 — Clean Layer DDL + Raw-to-Clean Transform

Status: PASS

Completed items:

- Created raw-to-clean transform script.
- Created / patched `clean.clean_bc`.
- Created / patched `clean.clean_pic_list`.
- Used safe reload approach because existing `clean.clean_bc` had dependent views.
- Avoided `DROP TABLE ... CASCADE` to prevent deleting existing DQ and snapshot views.
- Patched existing clean tables using `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`.
- Reloaded clean tables from raw tables.
- Parsed source dates using MM/DD/YYYY.
- Converted amount fields from raw text to numeric.
- Converted aging and closing duration fields to integer.
- Normalized status fields to uppercase.
- Converted missing / invalid PIC values such as `#N/A`, `N/A`, `NA`, and blank to `UNCLASSIFIED`.
- Preserved metadata:
  - `source_file_name`
  - `loaded_at`
  - `cleaned_at`

Created file:

```text
01_database/transform/003_transform_raw_to_clean.sql
```

Important implementation note:

```text
The first transform version attempted DROP TABLE on clean.clean_bc.
PostgreSQL blocked the drop because dependent views already existed:
- clean.vw_dq_bc_key_check
- clean.vw_dq_bc_orphan_pic_check
- clean.vw_dq_bc_amount_check
- snapshot.vw_latest_bc_daily_status_snapshot

Decision:
Do not use DROP ... CASCADE because it could remove existing DQ and snapshot views.
Use safe reload instead:
- CREATE TABLE IF NOT EXISTS
- ALTER TABLE ADD COLUMN IF NOT EXISTS
- TRUNCATE
- INSERT from raw
```

Additional issue resolved:

```text
Existing clean tables did not contain newer metadata or target columns such as loaded_at and ar_deadline_or_merge_invoice_notes.
Resolution: safe reload v3 adds all required columns with ALTER TABLE ADD COLUMN IF NOT EXISTS before insert.
```

Final clean row count validation:

```text
clean.clean_bc       | actual_row_count 8266 | expected_row_count 8266 | PASS
clean.clean_pic_list | actual_row_count 69   | expected_row_count 69   | PASS
```

Control note:

```text
Phase 7 validates clean row count only.
Detailed clean data quality validation is handled in Phase 8.
```

Commit message:

```text
feat: add raw to clean transform
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 8 — Clean Layer Validation

Status: PASS

Completed items:

- Created clean layer validation script.
- Validated raw vs clean row count.
- Validated BC key integrity.
- Validated PIC key integrity.
- Validated duplicate BC risk.
- Validated date parsing for:
  - `event_start_date`
  - `event_end_date`
  - `recording_period_date`
  - `latest_invoice_date`
- Validated amount negative check.
- Validated `UNCLASSIFIED` PIC count.
- Validated PIC orphan check.
- Validated billing/event status baseline.
- Validated clean metadata.
- Confirmed final clean validation summary PASS.

Created file:

```text
01_database/validation/003_validate_clean_layer.sql
```

Key validation results:

```text
BC raw vs clean  | raw 8266 | clean 8266 | expected 8266 | PASS
PIC raw vs clean | raw 69   | clean 69   | expected 69   | PASS
```

Date parsing results:

```text
event_end_date        | raw_non_blank 8266 | clean_parsed 8266 | failed 0 | PASS
event_start_date      | raw_non_blank 8266 | clean_parsed 8266 | failed 0 | PASS
latest_invoice_date   | raw_non_blank 7730 | clean_parsed 7730 | failed 0 | PASS
recording_period_date | raw_non_blank 8193 | clean_parsed 8193 | failed 0 | PASS
```

Final summary:

```text
bc_key_integrity      | PASS
negative_amount_check | PASS
pic_key_integrity     | PASS
pic_orphan_check      | PASS
row_count_bc          | PASS
row_count_pic         | PASS
```

Commit message:

```text
test: add clean layer validation
```

Validation result: PASS
Risk level after control: LOW

---

# Phase 9 — Snapshot Layer Build and Validation

Status: PASS

Phase 9 is split into:

- Phase 9.1 — Create snapshot table DDL
- Phase 9.2 — Create snapshot run function
- Phase 9.3 — Execute first snapshot
- Phase 9.4 — Create latest snapshot views
- Phase 9.5 — Snapshot layer validation

---

## Phase 9.1 — Create Snapshot Table DDL

Status: PASS

Completed items:

- Created snapshot schema objects.
- Created / patched `snapshot.snapshot_run_log`.
- Created / patched `snapshot.bc_daily_status_snapshot`.
- Created / patched `snapshot.bc_daily_issue_history`.
- Added key snapshot v1.1 fields:
  - `is_open_unbilled`
  - `is_closed_fully_invoiced`
  - `is_reported_excluded`
  - `is_partial_invoice`
  - `is_over_invoiced_review`
  - `is_unclassified_pic`
  - `open_rab_exposure_amount`
  - `invoice_gap_amount`
  - `remaining_invoice_amount`
  - `high_risk_flag`
  - `urgent_flag`
  - `risk_level`
  - `needs_manual_review_flag`
  - `data_quality_flag`
  - `data_quality_issue_count`
  - `issue_source_text`
- Created supporting indexes.

Created file:

```text
01_database/snapshot/004_create_snapshot_tables.sql
```

DDL validation result:

```text
snapshot.bc_daily_issue_history   | PASS
snapshot.bc_daily_status_snapshot | PASS
snapshot.snapshot_run_log         | PASS
```

Key column validation result:

```text
snapshot.bc_daily_issue_history   | issue_source_text        | PASS
snapshot.bc_daily_status_snapshot | bc_number                | PASS
snapshot.bc_daily_status_snapshot | high_risk_flag           | PASS
snapshot.bc_daily_status_snapshot | invoice_completion_ratio | PASS
snapshot.bc_daily_status_snapshot | is_open_unbilled         | PASS
snapshot.bc_daily_status_snapshot | is_reported_excluded     | PASS
snapshot.bc_daily_status_snapshot | open_rab_exposure_amount | PASS
snapshot.bc_daily_status_snapshot | snapshot_date            | PASS
snapshot.snapshot_run_log         | snapshot_date            | PASS
snapshot.snapshot_run_log         | snapshot_run_id          | PASS
```

Commit message:

```text
feat: add snapshot table ddl
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 9.2 — Create Snapshot Run Function

Status: PASS

Completed items:

- Created function `snapshot.run_bc_daily_snapshot(date, text, text)`.
- Function inserts snapshot run log.
- Function inserts `snapshot.bc_daily_status_snapshot`.
- Function inserts `snapshot.bc_daily_issue_history`.
- Function calculates snapshot v1.1 derived fields.
- Function marks latest snapshot of day.
- Function updates run log with completed status and row counts.
- Function validation PASS.

Created file:

```text
01_database/snapshot/005_create_snapshot_run_function.sql
```

Daily snapshot command:

```sql
SELECT snapshot.run_bc_daily_snapshot(CURRENT_DATE, '1600_WIB', 'daily_csv_upload');
```

Issue resolved:

```text
PostgreSQL rejected CREATE OR REPLACE FUNCTION because a prior function with same signature had a different parameter name.
Resolution: DROP FUNCTION IF EXISTS snapshot.run_bc_daily_snapshot(date, text, text) before CREATE OR REPLACE FUNCTION.
```

Additional patch:

```text
responsibility_type for REPORTED records was changed from EXCLUDED to UNKNOWN to remain compatible with existing snapshot responsibility constraint.
REPORTED exclusion is still represented by is_reported_excluded = true and detected_issue_category = REPORTED_EXCLUDED.
```

Function validation:

```text
snapshot.run_bc_daily_snapshot(date,text,text) | PASS
```

Commit message:

```text
feat: add snapshot run function
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 9.3 — Execute First Snapshot

Status: PASS

Completed items:

- Created snapshot execution script.
- Executed first snapshot using `snapshot.run_bc_daily_snapshot`.
- Snapshot run completed successfully.
- Snapshot row count matched clean row count.
- Issue history row count matched clean row count.
- Latest snapshot flag validated.

Created file:

```text
01_database/snapshot/006_execute_first_snapshot.sql
```

Snapshot command executed:

```sql
SELECT snapshot.run_bc_daily_snapshot(CURRENT_DATE, '1600_WIB', 'daily_csv_upload');
```

Final successful snapshot result:

```text
snapshot_run_id = 3
snapshot_date = 2026-05-15
snapshot_cutoff_label = 1600_WIB
source_type = daily_csv_upload
total_clean_bc_rows = 8266
total_snapshot_rows = 8266
total_issue_history_rows = 8266
snapshot_status = COMPLETED
validation_result = PASS
risk_level = LOW
```

Snapshot row count validation:

```text
snapshot.bc_daily_issue_history   | 8266 | 8266 | PASS
snapshot.bc_daily_status_snapshot | 8266 | 8266 | PASS
```

Latest snapshot of day validation:

```text
snapshot_date 2026-05-15 | latest_snapshot_rows 8266 | latest_flag_true_count 8266 | PASS
```

Issue resolved:

```text
First execution attempt failed because existing check constraint chk_snapshot_responsibility rejected responsibility_type = EXCLUDED.
Resolution: patch function so REPORTED rows use responsibility_type = UNKNOWN while REPORTED exclusion remains controlled by is_reported_excluded = true.
```

Commit message:

```text
feat: execute first bc daily snapshot
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 9.4 — Create Latest Snapshot Views

Status: PASS

Completed items:

- Created latest completed snapshot run view.
- Created latest BC daily status snapshot view.
- Created latest issue history view.
- Created latest snapshot KPI control view.
- Validated view existence.
- Validated latest view row count.
- Validated KPI control preview.
- Patched Average Aging Open BC logic.

Created file:

```text
01_database/snapshot/007_create_latest_snapshot_views.sql
```

Views created:

```text
snapshot.vw_latest_snapshot_run
snapshot.vw_latest_bc_daily_status_snapshot
snapshot.vw_latest_bc_daily_issue_history
snapshot.vw_latest_snapshot_kpi_control
```

Issue resolved:

```text
Initial view script selected snapshot_row_id and issue_history_id.
Existing snapshot tables came from an earlier structure and did not contain those columns.
Resolution: latest views no longer select snapshot_row_id or issue_history_id.
```

View existence validation:

```text
snapshot.vw_latest_bc_daily_issue_history   | PASS
snapshot.vw_latest_bc_daily_status_snapshot | PASS
snapshot.vw_latest_snapshot_kpi_control     | PASS
snapshot.vw_latest_snapshot_run             | PASS
```

Latest view row count validation:

```text
snapshot.vw_latest_bc_daily_issue_history   | 8266 | 8266 | PASS
snapshot.vw_latest_bc_daily_status_snapshot | 8266 | 8266 | PASS
```

KPI control preview after patch:

```text
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

Average Aging Open BC logic correction:

```text
Initial KPI control average aging returned a negative value because it counted all open BC, including ON GOING events and negative aging.
Corrected rule:
Average Aging Open BC only includes:
- is_open_unbilled = true
- event_status = 'ENDED'
- unbilled_aging_days > 0
```

Commit messages:

```text
feat: add latest snapshot views
fix: refine average aging open bc logic
```

Validation result: PASS
Risk level after control: LOW

---

## Phase 9.5 — Snapshot Layer Validation

Status: PASS

Completed items:

- Created snapshot layer validation script.
- Validated latest snapshot run log.
- Validated latest snapshot view row count.
- Validated snapshot key integrity.
- Validated required snapshot control fields.
- Validated REPORTED exclusion.
- Validated open exposure logic.
- Validated high risk logic.
- Validated UNCLASSIFIED PIC logic.
- Validated Average Aging Open BC logic.
- Validated KPI control view.
- Validated snapshot issue history.
- Validated daily movement readiness.
- Validated final snapshot summary.

Created file:

```text
01_database/snapshot/008_validate_snapshot_layer.sql
```

KPI control validation:

```text
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
validation_result = PASS
```

Issue history validation:

```text
issue_history_latest_run | issue_history_row_count 8266 | blank_issue_source_text_count 0 | null_detected_issue_category_count 0 | null_detected_blocker_count 0 | PASS
```

Daily movement readiness validation:

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

Commit message:

```text
test: add snapshot layer validation
```

Validation result: PASS
Risk level after control: LOW

---

# Current PostgreSQL State

Database:

```text
finance_ops_dev
```

Schemas:

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

Current snapshot views:

```text
snapshot.vw_latest_snapshot_run
snapshot.vw_latest_bc_daily_status_snapshot
snapshot.vw_latest_bc_daily_issue_history
snapshot.vw_latest_snapshot_kpi_control
```

Current confirmed row counts:

```text
raw.raw_bc_source    = 8266
raw.raw_pic_list     = 69
clean.clean_bc       = 8266
clean.clean_pic_list = 69
latest snapshot      = 8266
latest issue history = 8266
```

Current latest snapshot:

```text
snapshot_run_id = 3
snapshot_date = 2026-05-15
snapshot_cutoff_label = 1600_WIB
source_type = daily_csv_upload
validation_result = PASS
risk_level = LOW
```

---

# Current Validation Summary

| Area | Status | Risk |
|---|---|---|
| Repo safety foundation | PASS | LOW |
| GitHub repository setup | PASS | LOW |
| Repository folder structure | PASS | LOW |
| PostgreSQL installation | PASS | LOW |
| PostgreSQL PATH / psql | PASS | LOW |
| PostgreSQL login | PASS | LOW |
| Database creation | PASS | LOW |
| Schema creation | PASS | LOW |
| Schema validation | PASS | LOW |
| Masked source profile | PASS | LOW |
| Raw table build | PASS | LOW |
| Raw CSV load | PASS | LOW |
| Raw load validation | PASS | LOW |
| Raw key integrity | PASS | LOW |
| Raw column count validation | PASS | LOW |
| Clean transform row count | PASS | LOW |
| Clean layer validation | PASS | LOW |
| Snapshot table DDL | PASS | LOW |
| Snapshot function | PASS | LOW |
| First snapshot execution | PASS | LOW |
| Latest snapshot views | PASS | LOW |
| Snapshot layer validation | PASS | LOW |
| Daily movement readiness | PASS | LOW |
| Approved SQL examples | NOT STARTED | MEDIUM |
| Power BI connection | NOT STARTED | MEDIUM |
| Power BI semantic model | NOT STARTED | MEDIUM |
| DAX validation | NOT STARTED | MEDIUM |
| Power BI vs SQL reconciliation | NOT STARTED | MEDIUM |

---

# Current Hold Point

We are holding after:

```text
Phase 9.5 — Snapshot Layer Validation
```

Last validation result:

```text
Snapshot layer validation PASS
Latest snapshot rows = 8266
Latest issue history rows = 8266
Daily movement readiness = PASS
```

Next recommended phase:

```text
Phase 10 — Approved SQL Examples / KPI SQL Control
```

---

# Phase 10 — Approved SQL Examples / KPI SQL Control

Status: PASS
Validation Date: 2026-05-15
Risk Level: LOW
Technical Commit: c17c338 — Add phase 10 approved KPI SQL controls

Purpose:
Create and validate approved SQL examples and KPI reconciliation control for the Unbilled Monitoring dashboard.

Files Created:
- 01_database/approved_sql_examples/010_approved_kpi_control_examples.sql
- 05_tests/reconciliation_tests/010_validate_kpi_control_vs_latest_snapshot.sql

Validation Output:
- total_metric_checks = 18
- passed_metric_checks = 18
- failed_metric_checks = 0
- phase10_validation_result = PASS
- risk_level = LOW

Controls Validated:
- KPI control view matches latest snapshot recalculation.
- Open backlog uses is_open_unbilled.
- Open exposure uses open_rab_exposure_amount.
- REPORTED is excluded from active backlog.
- Average Aging Open BC uses open + ENDED + aging > 0.
- Daily movement readiness = PASS because distinct_snapshot_dates = 2.
- No actual cashflow logic was created.

KPI Baseline Confirmed:
- total_bc_count = 8266
- open_bc_count = 8145
- open_rab_exposure_amount = 4,956,993,250,804.46
- high_risk_bc_count = 3
- high_risk_rab_exposure_amount = 23,820,974,461.00
- reported_excluded_bc_count = 112
- unclassified_pic_count = 12
- manual_review_bc_count = 20
- average_aging_open_bc = 51.0055248618784530

Validation Result:
PASS

Next Phase:
Phase 11 — Power BI Semantic Model / Dashboard Model Preparation

# Phase 11 ? Power BI Connection / Semantic Model Preparation

Status: PASS
Validation Date: 2026-05-15
Risk Level: LOW
Technical Commit: 514b3c2 ? Add phase 11 Power BI source readiness validation

## Purpose

Validate Power BI source readiness before semantic model build, DAX development, and dashboard visual creation.

## Files Created

- `01_database/validation/011_validate_powerbi_source_readiness.sql`
- `02_powerbi/semantic_model/phase11_powerbi_connection_plan.md`

## Validation Output

- `total_checks = 67`
- `passed_checks = 67`
- `failed_checks = 0`
- `phase11_validation_result = PASS`
- `risk_level = LOW`

## Controls Validated

- Required Power BI source objects exist.
- Required Power BI source columns exist.
- Latest status view row count matches KPI control total BC count.
- Latest issue history row count matches KPI control total BC count.
- KPI control view returns one row.
- PIC dimension is non-empty.
- BC key is not null or blank.
- BC key is unique in latest status view.
- BC key is unique in latest issue history view.
- Snapshot history key is unique by snapshot run and BC.
- PIC relationship has no orphan records excluding `UNCLASSIFIED`.

## Approved Power BI Source Objects

- `snapshot.vw_latest_bc_daily_status_snapshot`
- `snapshot.vw_latest_snapshot_kpi_control`
- `snapshot.vw_latest_bc_daily_issue_history`
- `snapshot.bc_daily_status_snapshot`
- `clean.clean_pic_list`

## Validation Result

PASS

## Risk Level

LOW

## Next Phase

Phase 12 ? Power BI Semantic Model Build / Relationship Setup

# Phase 12 — Power BI Semantic Model

Status: NOT STARTED

Pending tasks:

- [ ] Set `snapshot.vw_latest_bc_daily_status_snapshot` or `snapshot.bc_daily_status_snapshot` as main fact.
- [ ] Set `snapshot.vw_latest_snapshot_kpi_control` as reconciliation/helper table.
- [ ] Set `snapshot.vw_latest_bc_daily_issue_history` as issue detail table.
- [ ] Set `clean.clean_pic_list` as PIC dimension.
- [ ] Set `dim_date` as date dimension.
- [ ] Create date relationship to snapshot fact.
- [ ] Create PIC relationship.
- [ ] Set relationships to single direction.
- [ ] Avoid fact-to-fact relationship.
- [ ] Hide technical columns.
- [ ] Validate cardinality.
- [ ] Validate filter direction.
- [ ] Validate no many-to-many issue unless explicitly bridged.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 13 — DAX Measure Build

Status: NOT STARTED

Pending tasks:

- [ ] Create measure table.
- [ ] Add Executive Overview measures.
- [ ] Add AR Controller measures.
- [ ] Add PIC Operation Scoring measures.
- [ ] Add Data Quality measures.
- [ ] Add Daily Movement measures.
- [ ] Use snapshot v1.1 fields.
- [ ] Use `is_open_unbilled` for open backlog.
- [ ] Use `open_rab_exposure_amount` for open exposure.
- [ ] Avoid `bill_status <> "BILLED"` as open logic.
- [ ] Apply Average Aging Open BC rule:
  - `is_open_unbilled = true`
  - `event_status = "ENDED"`
  - `unbilled_aging_days > 0`
- [ ] Save DAX library to repo.
- [ ] Test DAX in actual PBIX.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 14 — Executive Overview Page

Status: NOT STARTED

Pending tasks:

- [ ] Create Total Open BC card.
- [ ] Create Open RAB Exposure card.
- [ ] Create High Risk BC Count card.
- [ ] Create High Risk RAB Exposure card.
- [ ] Create Average Aging Open BC card.
- [ ] Create UNCLASSIFIED PIC Count card.
- [ ] Create open exposure trend visual.
- [ ] Create aging bucket visual.
- [ ] Create top PIC risk visual.
- [ ] Create top high risk BC table.
- [ ] Validate page filters.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 15 — AR Controller Page

Status: NOT STARTED

Pending tasks:

- [ ] Create aging bucket analysis.
- [ ] Create invoice completion analysis.
- [ ] Create customer exposure ranking.
- [ ] Create document/blocker analysis.
- [ ] Create follow-up BC table.
- [ ] Add AR-focused slicers.
- [ ] Validate AR KPI logic.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 16 — PIC Operation Scoring Page

Status: NOT STARTED

Pending tasks:

- [ ] Create PIC ranking by open exposure.
- [ ] Create PIC ranking by high risk exposure.
- [ ] Create PIC average aging visual.
- [ ] Create manual review by PIC.
- [ ] Separate `UNCLASSIFIED` as correction bucket.
- [ ] Validate PIC relationship.
- [ ] Validate no many-to-many issue.
- [ ] Ensure UNCLASSIFIED is not treated as PIC performance penalty.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 17 — Data Quality / Exception Page

Status: NOT STARTED

Pending tasks:

- [ ] Create data quality KPI cards.
- [ ] Create manual review count.
- [ ] Create UNCLASSIFIED PIC count.
- [ ] Create partial invoice review table.
- [ ] Create over-invoiced review table.
- [ ] Create missing/invalid field exception table.
- [ ] Validate exception logic.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 18 — Power BI vs SQL Reconciliation

Status: NOT STARTED

Pending tasks:

- [ ] Run approved SQL Executive KPI.
- [ ] Compare SQL result with Power BI card values.
- [ ] Reconcile Total Open BC.
- [ ] Reconcile Open RAB Exposure.
- [ ] Reconcile High Risk BC Count.
- [ ] Reconcile High Risk RAB Exposure.
- [ ] Reconcile Average Aging Open BC.
- [ ] Reconcile UNCLASSIFIED PIC Count.
- [ ] Validate amount rounding.
- [ ] Validate snapshot date filter.
- [ ] Validate visual-level filters.
- [ ] Document mismatch if any.
- [ ] Fix DAX/model if mismatch.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 19 — Dashboard QA

Status: NOT STARTED

Pending tasks:

- [ ] Check slicers.
- [ ] Check filter direction.
- [ ] Check relationship behavior.
- [ ] Check blank values.
- [ ] Check duplicated BC risk.
- [ ] Check performance.
- [ ] Check refresh.
- [ ] Check visual naming.
- [ ] Check measure formatting.
- [ ] Check tooltip clarity.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Phase 20 — Documentation

Status: IN PROGRESS

Completed documentation:

- [x] Repo safety foundation documented.
- [x] Repository structure documented.
- [x] PostgreSQL setup documented.
- [x] Masked source profile documented.
- [x] Raw layer load documented.
- [x] Raw validation documented.
- [x] Clean row count transform documented.
- [x] Clean validation documented.
- [x] Snapshot table DDL documented.
- [x] Snapshot function documented.
- [x] Snapshot execution documented.
- [x] Latest snapshot views documented.
- [x] Snapshot validation documented.

Pending documentation:

- [ ] Approved SQL examples.
- [ ] Power BI semantic model.
- [ ] DAX measures.
- [ ] Dashboard page mapping.
- [ ] KPI definitions.
- [ ] Reconciliation result.
- [ ] Known limitations.
- [ ] Next improvement backlog.

Validation result: IN PROGRESS
Risk level before control: LOW

---

# Phase 21 — Production Preparation

Status: NOT STARTED

Pending tasks:

- [ ] Configure scheduled PostgreSQL refresh.
- [ ] Configure snapshot daily routine.
- [ ] Configure Power BI refresh.
- [ ] Configure gateway if needed.
- [ ] Configure access control.
- [ ] Prepare deployment checklist.
- [ ] Prepare maintenance checklist.
- [ ] Prepare issue log.
- [ ] Prepare next sprint backlog.

Validation result: NOT STARTED
Risk level before control: MEDIUM

---

# Important Safety Notes

- Real data must remain outside the repository.
- Masked sample data may be stored only under `03_sample_data_masked/`.
- `.env` must not be committed.
- `.env.example` is allowed.
- PBIX files with embedded real data must not be committed.
- Database dumps must not be committed.
- Connection strings must not be committed.
- Passwords and credentials must not be committed.
- Amount fields are currently accepted as safe by user confirmation, but must be reviewed again if repository visibility changes or the repository is shared externally.

---

# Known Issues Resolved

## Issue 1 — SQL pasted directly into PowerShell

Status: RESOLVED

Problem:

```text
PowerShell returned parser errors such as:
Missing expression after unary operator '--'
```

Cause:

```text
SQL script content was pasted directly into PowerShell instead of being saved as .sql and executed through psql.
```

Resolution:

```text
Save SQL script as .sql file and execute using psql -f.
```

---

## Issue 2 — psql `\copy` multiline parse error

Status: RESOLVED

Problem:

```text
\copy: parse error at end of line
```

Cause:

```text
psql meta-command \copy is line-based and should be written as one full line.
```

Resolution:

```text
Rewrite \copy commands as one-line commands.
```

---

## Issue 3 — Existing clean table blocked DROP

Status: RESOLVED

Problem:

```text
cannot drop table clean.clean_bc because other objects depend on it
```

Dependent objects included:

```text
clean.vw_dq_bc_key_check
clean.vw_dq_bc_orphan_pic_check
clean.vw_dq_bc_amount_check
snapshot.vw_latest_bc_daily_status_snapshot
```

Cause:

```text
Existing DQ and snapshot views depended on clean.clean_bc.
```

Resolution:

```text
Do not use DROP ... CASCADE.
Use safe reload with ALTER TABLE ADD COLUMN IF NOT EXISTS, TRUNCATE, then INSERT.
```

---

## Issue 4 — Existing clean tables missing new columns

Status: RESOLVED

Problem examples:

```text
column "loaded_at" of relation "clean_pic_list" does not exist
column "ar_deadline_or_merge_invoice_notes" of relation "clean_bc" does not exist
```

Cause:

```text
Clean tables already existed from previous version and did not include all target columns.
CREATE TABLE IF NOT EXISTS did not patch existing structure.
```

Resolution:

```text
Patch all required target columns using ALTER TABLE ADD COLUMN IF NOT EXISTS.
```

---

## Issue 5 — PowerShell UTF-8 BOM in SQL file

Status: RESOLVED

Problem:

```text
ERROR: syntax error at or near "ï»¿"
LINE 1: ï»¿-- SQL content here
```

Cause:

```text
SQL file was created with UTF-8 BOM.
PostgreSQL interpreted BOM as invalid characters.
```

Resolution:

```text
Prioritize Python for creating/overwriting project files.
Write files using encoding='utf-8' without BOM.
Avoid PowerShell Set-Content for SQL/MD file creation.
```

---

## Issue 6 — Linux heredoc syntax used in Windows PowerShell

Status: RESOLVED

Problem:

```text
python - <<'PY'
Missing file specification after redirection operator.
```

Cause:

```text
Linux/macOS heredoc syntax was provided for Windows PowerShell.
```

Resolution:

```text
Use Windows PowerShell-compatible Python pipe:
@'
python code
'@ | python -
```

Project rule added:

```text
Do not provide non-Windows terminal syntax for this project unless explicitly requested.
Do not use placeholders such as {target}, <USER>, or SQL CONTENT HERE.
If path or file name is uncertain, ask user first.
```

---

## Issue 7 — Existing snapshot responsibility constraint rejected EXCLUDED

Status: RESOLVED

Problem:

```text
new row for relation "bc_daily_status_snapshot" violates check constraint "chk_snapshot_responsibility"
```

Cause:

```text
Function inserted responsibility_type = EXCLUDED for REPORTED rows, but existing constraint did not allow that value.
```

Resolution:

```text
Set responsibility_type = UNKNOWN for REPORTED rows.
Keep REPORTED exclusion controlled by:
- is_reported_excluded = true
- detected_issue_category = REPORTED_EXCLUDED
- detected_blocker = REPORTED_EXCLUDED
```

---

## Issue 8 — Latest snapshot view selected columns not present in existing table

Status: RESOLVED

Problem:

```text
column s.snapshot_row_id does not exist
```

Cause:

```text
Existing snapshot table was created from an earlier structure and did not contain snapshot_row_id / issue_history_id.
```

Resolution:

```text
Latest snapshot views no longer select snapshot_row_id or issue_history_id.
```

---

## Issue 9 — Average Aging Open BC returned negative value

Status: RESOLVED

Problem:

```text
average_aging_open_bc = -1.18
```

Cause:

```text
Initial KPI control view averaged all open BC, including ON GOING events and negative aging values.
```

Resolution:

```text
Average Aging Open BC now includes only:
- is_open_unbilled = true
- event_status = 'ENDED'
- unbilled_aging_days > 0
```

Validated result:

```text
average_aging_open_bc = 51.0055248618784530
```

---

# Project Operating Rules Added During This Session

## File Creation Rule

For new project files, the assistant must provide a ready-to-copy Windows terminal script that:

- Uses the confirmed full repository path.
- Creates the target folder if missing.
- Writes the file to the exact target path.
- Uses Python by default.
- Writes with `encoding='utf-8'` without BOM.
- Checks first bytes to ensure no BOM.
- Avoids placeholders.
- Uses PowerShell-compatible syntax only.

## Preferred File Writer Rule

Prioritize Python for creating or overwriting project files.

Avoid:

```text
PowerShell Set-Content for SQL/MD
Linux/macOS heredoc syntax
Manual file creation unless user explicitly asks
```

Use:

```text
@'
python code
'@ | python -
```

with full confirmed paths.

---

# Current Production Readiness

Current production readiness:

```text
NOT YET
```

Reason:

- Raw layer is validated.
- Clean layer is validated.
- Snapshot layer is validated.
- Latest views are validated.
- Daily movement readiness is now PASS.
- Approved SQL examples are not yet created.
- Power BI connection has not yet been performed.
- Semantic model has not yet been validated.
- DAX measures have not yet been tested in actual PBIX.
- Power BI vs SQL reconciliation has not yet been performed.
- User final validation is not yet complete.

Current validation role:

```text
Foundation, source profile, raw layer, clean layer, snapshot layer, latest views, and snapshot validation are PASS.
Power BI, DAX, and reconciliation are still pending.
```

---

# Next Action

Next phase:

```text
Phase 10 — Approved SQL Examples / KPI SQL Control
```

Immediate next file to create:

```text
01_database/approved_sql_examples/009_approved_sql_examples_snapshot_kpi.sql
```

Immediate next validation focus:

- Executive Overview SQL
- AR Controller Aging SQL
- Top High Risk BC SQL
- PIC Score Base SQL
- BC Investigation SQL
- Data Quality / Exception SQL
- SQL result reconciliation against `snapshot.vw_latest_snapshot_kpi_control`

Expected next validation result target:

```text
PASS or NEEDS REVIEW with documented exceptions
```

---

# Latest Validation Result

Validation result:

```text
PASS up to Phase 11
```

Risk level:

```text
LOW after Phase 11 controls
```

Next phase risk before control:

```text
MEDIUM for Phase 12 Power BI Semantic Model Build / Relationship Setup
```

---

## Phase 12 — Power BI Semantic Model Refactor / Relationship Setup

Marker: PHASE_12_SEMANTIC_MODEL_REFACTOR_APPEND_2026_05_15

Status: IN PROGRESS  
Validation Result: NEEDS REVIEW  
Risk Level: LOW  
Updated: 2026-05-15

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

---

## Phase 12 — SQL Reporting Views Validation Result

Marker: PHASE_12_SQL_VALIDATION_PASS_STRUCTURE_APPEND_2026_05_15

Updated: 2026-05-15  
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
