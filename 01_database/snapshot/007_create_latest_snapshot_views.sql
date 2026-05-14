\set ON_ERROR_STOP on

\echo 'START Phase 9.4 - Create Latest Snapshot Views v2'

CREATE SCHEMA IF NOT EXISTS snapshot;

-- =========================================================
-- 1. Drop views in dependency-safe order
-- =========================================================

DROP VIEW IF EXISTS snapshot.vw_latest_snapshot_kpi_control;
DROP VIEW IF EXISTS snapshot.vw_latest_bc_daily_issue_history;
DROP VIEW IF EXISTS snapshot.vw_latest_bc_daily_status_snapshot;
DROP VIEW IF EXISTS snapshot.vw_latest_snapshot_run;

-- =========================================================
-- 2. Latest completed snapshot run view
-- =========================================================

CREATE VIEW snapshot.vw_latest_snapshot_run AS
SELECT
    snapshot_run_id,
    snapshot_date,
    snapshot_timestamp,
    snapshot_cutoff_label,
    source_type,
    source_file_name,
    total_clean_bc_rows,
    total_snapshot_rows,
    total_issue_history_rows,
    snapshot_status,
    validation_result,
    risk_level,
    notes,
    created_at,
    completed_at
FROM snapshot.snapshot_run_log
WHERE snapshot_status = 'COMPLETED'
  AND validation_result = 'PASS'
ORDER BY snapshot_run_id DESC
LIMIT 1;

-- =========================================================
-- 3. Latest BC daily status snapshot view
-- Note:
--   Do not select snapshot_row_id because existing snapshot table may come
--   from an earlier version and may not contain that column.
-- =========================================================

CREATE VIEW snapshot.vw_latest_bc_daily_status_snapshot AS
SELECT
    s.snapshot_run_id,
    s.snapshot_date,
    s.snapshot_timestamp,
    s.snapshot_cutoff_label,
    s.is_latest_snapshot_of_day,
    s.source_row_no,
    s.bc_number,
    s.event_name,
    s.customer_name,
    s.pic_internal_code,
    s.event_category,
    s.event_status,
    s.billing_status,
    s.invoice_number,
    s.event_start_date,
    s.event_end_date,
    s.recording_period_date,
    s.latest_invoice_date,
    s.snapshot_year_month,
    s.event_end_year_month,
    s.invoice_year_month,
    s.event_value_amount,
    s.rab_budget_amount,
    s.total_invoiced_amount,
    s.umk_released_amount,
    s.umk_issued_amount,
    s.handling_fee,
    s.invoice_completion_ratio,
    s.invoice_completion_bucket,
    s.bc_closing_status,
    s.unbilled_aging_days,
    s.aging_bucket,
    s.closing_duration_days,
    s.closing_duration_bucket,
    s.is_open_unbilled,
    s.is_closed_fully_invoiced,
    s.is_reported_excluded,
    s.is_partial_invoice,
    s.is_over_invoiced_review,
    s.is_unclassified_pic,
    s.open_rab_exposure_amount,
    s.invoice_gap_amount,
    s.remaining_invoice_amount,
    s.high_risk_flag,
    s.urgent_flag,
    s.risk_level,
    s.needs_manual_review_flag,
    s.data_quality_flag,
    s.data_quality_issue_count,
    s.billing_remarks,
    s.document_status_or_missing_notes,
    s.ar_deadline_or_merge_invoice_notes,
    s.pic_user_contact,
    s.po_status_or_po_number,
    s.umk_status,
    s.issue_source_text,
    s.detected_issue_category,
    s.detected_blocker,
    s.responsibility_type,
    s.issue_confidence_level,
    s.classification_method,
    s.source_file_name,
    s.source_row_hash,
    s.record_hash,
    s.loaded_at,
    s.cleaned_at,
    s.created_at
FROM snapshot.bc_daily_status_snapshot s
JOIN snapshot.vw_latest_snapshot_run lr
    ON s.snapshot_run_id = lr.snapshot_run_id;

-- =========================================================
-- 4. Latest issue history view
-- Note:
--   Do not select issue_history_id because existing issue history table may
--   come from an earlier version and may not contain that column.
-- =========================================================

CREATE VIEW snapshot.vw_latest_bc_daily_issue_history AS
SELECT
    h.snapshot_run_id,
    h.snapshot_date,
    h.snapshot_timestamp,
    h.bc_number,
    h.pic_internal_code,
    h.billing_status,
    h.event_status,
    h.invoice_completion_bucket,
    h.bc_closing_status,
    h.raw_remarks,
    h.raw_missing_document_notes,
    h.raw_po_status,
    h.raw_umk_status,
    h.issue_source_text,
    h.detected_issue_category,
    h.detected_blocker,
    h.responsibility_type,
    h.issue_confidence_level,
    h.classification_method,
    h.needs_manual_review_flag,
    h.created_at
FROM snapshot.bc_daily_issue_history h
JOIN snapshot.vw_latest_snapshot_run lr
    ON h.snapshot_run_id = lr.snapshot_run_id;

-- =========================================================
-- 5. Latest snapshot KPI control view
-- Purpose:
--   Fast sanity check for Power BI reconciliation.
-- =========================================================

CREATE VIEW snapshot.vw_latest_snapshot_kpi_control AS
SELECT
    snapshot_run_id,
    snapshot_date,
    COUNT(*) AS total_bc_count,
    COUNT(*) FILTER (WHERE is_open_unbilled = true) AS open_bc_count,
    SUM(open_rab_exposure_amount) AS open_rab_exposure_amount,
    COUNT(*) FILTER (WHERE high_risk_flag = true) AS high_risk_bc_count,
    SUM(CASE WHEN high_risk_flag = true THEN open_rab_exposure_amount ELSE 0 END) AS high_risk_rab_exposure_amount,
    COUNT(*) FILTER (WHERE is_reported_excluded = true) AS reported_excluded_bc_count,
    COUNT(*) FILTER (WHERE is_unclassified_pic = true) AS unclassified_pic_count,
    COUNT(*) FILTER (WHERE needs_manual_review_flag = true) AS manual_review_bc_count,
    AVG(unbilled_aging_days) FILTER (WHERE is_open_unbilled = true) AS average_aging_open_bc
FROM snapshot.vw_latest_bc_daily_status_snapshot
GROUP BY
    snapshot_run_id,
    snapshot_date;

-- =========================================================
-- 6. View validation
-- =========================================================

\echo 'Running Phase 9.4 view existence validation...'

WITH required_views AS (
    SELECT 'snapshot.vw_latest_snapshot_run' AS view_name
    UNION ALL
    SELECT 'snapshot.vw_latest_bc_daily_status_snapshot'
    UNION ALL
    SELECT 'snapshot.vw_latest_bc_daily_issue_history'
    UNION ALL
    SELECT 'snapshot.vw_latest_snapshot_kpi_control'
),
view_validation AS (
    SELECT
        rv.view_name,
        CASE
            WHEN v.table_schema IS NOT NULL THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    FROM required_views rv
    LEFT JOIN information_schema.views v
        ON split_part(rv.view_name, '.', 1) = v.table_schema
       AND split_part(rv.view_name, '.', 2) = v.table_name
)
SELECT
    view_name,
    validation_result
FROM view_validation
ORDER BY view_name;

\echo 'Running Phase 9.4 latest snapshot row count validation...'

SELECT
    'snapshot.vw_latest_bc_daily_status_snapshot' AS view_name,
    COUNT(*) AS actual_row_count,
    8266 AS expected_row_count,
    CASE
        WHEN COUNT(*) = 8266 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot

UNION ALL

SELECT
    'snapshot.vw_latest_bc_daily_issue_history' AS view_name,
    COUNT(*) AS actual_row_count,
    8266 AS expected_row_count,
    CASE
        WHEN COUNT(*) = 8266 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_issue_history
ORDER BY view_name;

\echo 'Running Phase 9.4 KPI control preview...'

SELECT
    snapshot_run_id,
    snapshot_date,
    total_bc_count,
    open_bc_count,
    open_rab_exposure_amount,
    high_risk_bc_count,
    high_risk_rab_exposure_amount,
    reported_excluded_bc_count,
    unclassified_pic_count,
    manual_review_bc_count,
    average_aging_open_bc
FROM snapshot.vw_latest_snapshot_kpi_control;

\echo 'END Phase 9.4 - Create Latest Snapshot Views v2'
