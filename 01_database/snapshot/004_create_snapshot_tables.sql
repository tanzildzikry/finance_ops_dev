\set ON_ERROR_STOP on

\echo 'START Phase 9.1 - Create Snapshot Tables'

CREATE SCHEMA IF NOT EXISTS snapshot;

-- =========================================================
-- 1. Snapshot run log
-- Purpose:
--   Track each snapshot execution batch.
-- =========================================================

CREATE TABLE IF NOT EXISTS snapshot.snapshot_run_log (
    snapshot_run_id bigserial PRIMARY KEY
);

ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS snapshot_date date;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS snapshot_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS snapshot_cutoff_label text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS source_type text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS source_file_name text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS total_clean_bc_rows integer;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS total_snapshot_rows integer;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS total_issue_history_rows integer;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS snapshot_status text DEFAULT 'CREATED';
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS validation_result text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS risk_level text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE snapshot.snapshot_run_log ADD COLUMN IF NOT EXISTS completed_at timestamp without time zone;

-- =========================================================
-- 2. Main BC daily status snapshot table
-- Purpose:
--   Store daily BC status with derived business logic fields.
-- =========================================================

CREATE TABLE IF NOT EXISTS snapshot.bc_daily_status_snapshot (
    snapshot_row_id bigserial PRIMARY KEY
);

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS snapshot_run_id bigint;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS snapshot_date date;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS snapshot_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS snapshot_cutoff_label text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_latest_snapshot_of_day boolean DEFAULT true;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS source_row_no integer;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS bc_number text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_name text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS customer_name text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS pic_internal_code text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_category text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_status text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS billing_status text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS invoice_number text;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_start_date date;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_end_date date;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS recording_period_date date;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS latest_invoice_date date;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS snapshot_year_month text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_end_year_month text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS invoice_year_month text;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS event_value_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS rab_budget_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS total_invoiced_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS umk_released_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS umk_issued_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS handling_fee numeric;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS invoice_completion_ratio numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS invoice_completion_bucket text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS bc_closing_status text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS unbilled_aging_days integer;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS aging_bucket text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS closing_duration_days integer;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS closing_duration_bucket text;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_open_unbilled boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_closed_fully_invoiced boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_reported_excluded boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_partial_invoice boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_over_invoiced_review boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS is_unclassified_pic boolean;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS open_rab_exposure_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS invoice_gap_amount numeric;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS remaining_invoice_amount numeric;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS high_risk_flag boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS urgent_flag boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS risk_level text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS needs_manual_review_flag boolean;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS data_quality_flag text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS data_quality_issue_count integer;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS billing_remarks text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS document_status_or_missing_notes text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS ar_deadline_or_merge_invoice_notes text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS pic_user_contact text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS po_status_or_po_number text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS umk_status text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS issue_source_text text;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS detected_issue_category text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS detected_blocker text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS responsibility_type text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS issue_confidence_level text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS classification_method text;

ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS source_file_name text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS source_row_hash text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS record_hash text;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS loaded_at timestamp without time zone;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS cleaned_at timestamp without time zone;
ALTER TABLE snapshot.bc_daily_status_snapshot ADD COLUMN IF NOT EXISTS created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP;

-- =========================================================
-- 3. BC daily issue history table
-- Purpose:
--   Store issue/blocker text and classification history per BC per snapshot.
-- =========================================================

CREATE TABLE IF NOT EXISTS snapshot.bc_daily_issue_history (
    issue_history_id bigserial PRIMARY KEY
);

ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS snapshot_run_id bigint;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS snapshot_date date;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS snapshot_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS bc_number text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS pic_internal_code text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS billing_status text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS event_status text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS invoice_completion_bucket text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS bc_closing_status text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS raw_remarks text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS raw_missing_document_notes text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS raw_po_status text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS raw_umk_status text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS issue_source_text text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS detected_issue_category text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS detected_blocker text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS responsibility_type text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS issue_confidence_level text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS classification_method text;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS needs_manual_review_flag boolean;
ALTER TABLE snapshot.bc_daily_issue_history ADD COLUMN IF NOT EXISTS created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP;

-- =========================================================
-- 4. Indexes
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_snapshot_run_log_snapshot_date
    ON snapshot.snapshot_run_log (snapshot_date);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_run_id
    ON snapshot.bc_daily_status_snapshot (snapshot_run_id);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_date
    ON snapshot.bc_daily_status_snapshot (snapshot_date);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_bc_number
    ON snapshot.bc_daily_status_snapshot (bc_number);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_pic
    ON snapshot.bc_daily_status_snapshot (pic_internal_code);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_open
    ON snapshot.bc_daily_status_snapshot (is_open_unbilled);

CREATE INDEX IF NOT EXISTS idx_bc_daily_status_snapshot_risk
    ON snapshot.bc_daily_status_snapshot (risk_level);

CREATE INDEX IF NOT EXISTS idx_bc_daily_issue_history_date
    ON snapshot.bc_daily_issue_history (snapshot_date);

CREATE INDEX IF NOT EXISTS idx_bc_daily_issue_history_bc_number
    ON snapshot.bc_daily_issue_history (bc_number);

-- =========================================================
-- 5. DDL Validation
-- =========================================================

\echo 'Running Phase 9.1 DDL validation...'

WITH required_tables AS (
    SELECT 'snapshot.snapshot_run_log' AS table_name
    UNION ALL
    SELECT 'snapshot.bc_daily_status_snapshot'
    UNION ALL
    SELECT 'snapshot.bc_daily_issue_history'
),
table_validation AS (
    SELECT
        rt.table_name,
        CASE
            WHEN t.table_schema IS NOT NULL THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    FROM required_tables rt
    LEFT JOIN information_schema.tables t
        ON split_part(rt.table_name, '.', 1) = t.table_schema
       AND split_part(rt.table_name, '.', 2) = t.table_name
)
SELECT
    table_name,
    validation_result
FROM table_validation
ORDER BY table_name;

\echo 'Running Phase 9.1 key column validation...'

WITH required_columns AS (
    SELECT 'snapshot.bc_daily_status_snapshot' AS table_name, 'snapshot_date' AS column_name
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'bc_number'
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'is_open_unbilled'
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'open_rab_exposure_amount'
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'is_reported_excluded'
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'invoice_completion_ratio'
    UNION ALL SELECT 'snapshot.bc_daily_status_snapshot', 'high_risk_flag'
    UNION ALL SELECT 'snapshot.bc_daily_issue_history', 'issue_source_text'
    UNION ALL SELECT 'snapshot.snapshot_run_log', 'snapshot_run_id'
    UNION ALL SELECT 'snapshot.snapshot_run_log', 'snapshot_date'
),
column_validation AS (
    SELECT
        rc.table_name,
        rc.column_name,
        CASE
            WHEN c.column_name IS NOT NULL THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    FROM required_columns rc
    LEFT JOIN information_schema.columns c
        ON split_part(rc.table_name, '.', 1) = c.table_schema
       AND split_part(rc.table_name, '.', 2) = c.table_name
       AND rc.column_name = c.column_name
)
SELECT
    table_name,
    column_name,
    validation_result
FROM column_validation
ORDER BY table_name, column_name;

\echo 'END Phase 9.1 - Create Snapshot Tables'
