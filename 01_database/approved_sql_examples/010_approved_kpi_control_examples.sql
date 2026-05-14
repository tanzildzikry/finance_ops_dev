\set ON_ERROR_STOP on
\pset pager off

\echo 'PHASE 10 - APPROVED SQL EXAMPLES / KPI SQL CONTROL'
\echo 'SQL-10-001 - Executive KPI Summary from snapshot.vw_latest_snapshot_kpi_control'

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

\echo 'SQL-10-002 - Executive KPI Recalculation from snapshot.vw_latest_bc_daily_status_snapshot'

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
    AVG(unbilled_aging_days) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    ) AS average_aging_open_bc
FROM snapshot.vw_latest_bc_daily_status_snapshot
GROUP BY
    snapshot_run_id,
    snapshot_date;

\echo 'SQL-10-003 - Open Backlog Detail for AR Controller'

SELECT
    snapshot_date,
    bc_number,
    event_name,
    customer_name,
    pic_internal_code,
    event_category,
    event_status,
    billing_status,
    unbilled_aging_days,
    aging_bucket,
    rab_budget_amount,
    total_invoiced_amount,
    open_rab_exposure_amount,
    invoice_completion_ratio,
    invoice_completion_bucket,
    bc_closing_status,
    high_risk_flag,
    needs_manual_review_flag,
    issue_source_text
FROM snapshot.vw_latest_bc_daily_status_snapshot
WHERE is_open_unbilled = true
  AND is_reported_excluded = false
ORDER BY
    high_risk_flag DESC,
    open_rab_exposure_amount DESC,
    unbilled_aging_days DESC,
    bc_number
LIMIT 100;

\echo 'SQL-10-004 - Top High Risk BC'

SELECT
    snapshot_date,
    bc_number,
    event_name,
    customer_name,
    pic_internal_code,
    event_category,
    billing_status,
    unbilled_aging_days,
    rab_budget_amount,
    open_rab_exposure_amount,
    total_invoiced_amount,
    invoice_gap_amount,
    risk_level,
    issue_source_text
FROM snapshot.vw_latest_bc_daily_status_snapshot
WHERE high_risk_flag = true
ORDER BY
    open_rab_exposure_amount DESC,
    unbilled_aging_days DESC,
    bc_number;

\echo 'SQL-10-005 - REPORTED Exclusion Control'

SELECT
    COUNT(*) FILTER (WHERE billing_status = 'REPORTED') AS reported_source_count,
    COUNT(*) FILTER (
        WHERE billing_status = 'REPORTED'
          AND is_reported_excluded = true
    ) AS reported_excluded_count,
    COUNT(*) FILTER (
        WHERE billing_status = 'REPORTED'
          AND is_open_unbilled = true
    ) AS reported_in_open_backlog_count,
    COALESCE(SUM(open_rab_exposure_amount) FILTER (
        WHERE billing_status = 'REPORTED'
    ), 0) AS reported_open_rab_exposure_amount,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE billing_status = 'REPORTED'
              AND is_open_unbilled = true
        ) = 0
         AND COALESCE(SUM(open_rab_exposure_amount) FILTER (
            WHERE billing_status = 'REPORTED'
        ), 0) = 0
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot;

\echo 'SQL-10-006 - Average Aging Open BC Control'

SELECT
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    ) AS valid_average_aging_row_count,
    AVG(unbilled_aging_days) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    ) AS average_aging_open_bc,
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ON GOING'
    ) AS open_ongoing_rows_excluded_from_average,
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND unbilled_aging_days <= 0
    ) AS open_non_positive_aging_rows_excluded_from_average
FROM snapshot.vw_latest_bc_daily_status_snapshot;

\echo 'SQL-10-007 - Daily Movement Readiness'

SELECT
    COUNT(DISTINCT snapshot_date) AS distinct_snapshot_dates,
    CASE
        WHEN COUNT(DISTINCT snapshot_date) >= 2 THEN 'PASS'
        ELSE 'NEEDS REVIEW'
    END AS validation_result,
    CASE
        WHEN COUNT(DISTINCT snapshot_date) >= 2 THEN 'Daily movement is meaningful.'
        ELSE 'Daily movement is not meaningful yet because fewer than 2 snapshot dates exist.'
    END AS control_note
FROM snapshot.bc_daily_status_snapshot;
