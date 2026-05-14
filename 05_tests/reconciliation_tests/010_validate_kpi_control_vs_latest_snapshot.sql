\set ON_ERROR_STOP on
\pset pager off

\echo 'PHASE 10 VALIDATION - KPI CONTROL VS LATEST SNAPSHOT'

DROP VIEW IF EXISTS phase10_expected_baseline;
DROP VIEW IF EXISTS phase10_recalculated_kpi;
DROP VIEW IF EXISTS phase10_control_kpi;
DROP VIEW IF EXISTS phase10_baseline_validation;
DROP VIEW IF EXISTS phase10_reconciliation_validation;

CREATE TEMP VIEW phase10_expected_baseline AS
SELECT
    3::bigint AS snapshot_run_id,
    DATE '2026-05-15' AS snapshot_date,
    8266::numeric AS total_bc_count,
    8145::numeric AS open_bc_count,
    4956993250804.46::numeric AS open_rab_exposure_amount,
    3::numeric AS high_risk_bc_count,
    23820974461.00::numeric AS high_risk_rab_exposure_amount,
    112::numeric AS reported_excluded_bc_count,
    12::numeric AS unclassified_pic_count,
    20::numeric AS manual_review_bc_count,
    51.0055248618784530::numeric AS average_aging_open_bc;

CREATE TEMP VIEW phase10_control_kpi AS
SELECT
    snapshot_run_id,
    snapshot_date,
    total_bc_count::numeric AS total_bc_count,
    open_bc_count::numeric AS open_bc_count,
    open_rab_exposure_amount::numeric AS open_rab_exposure_amount,
    high_risk_bc_count::numeric AS high_risk_bc_count,
    high_risk_rab_exposure_amount::numeric AS high_risk_rab_exposure_amount,
    reported_excluded_bc_count::numeric AS reported_excluded_bc_count,
    unclassified_pic_count::numeric AS unclassified_pic_count,
    manual_review_bc_count::numeric AS manual_review_bc_count,
    average_aging_open_bc::numeric AS average_aging_open_bc
FROM snapshot.vw_latest_snapshot_kpi_control;

CREATE TEMP VIEW phase10_recalculated_kpi AS
SELECT
    snapshot_run_id,
    snapshot_date,
    COUNT(*)::numeric AS total_bc_count,
    COUNT(*) FILTER (WHERE is_open_unbilled = true)::numeric AS open_bc_count,
    SUM(open_rab_exposure_amount)::numeric AS open_rab_exposure_amount,
    COUNT(*) FILTER (WHERE high_risk_flag = true)::numeric AS high_risk_bc_count,
    SUM(CASE WHEN high_risk_flag = true THEN open_rab_exposure_amount ELSE 0 END)::numeric AS high_risk_rab_exposure_amount,
    COUNT(*) FILTER (WHERE is_reported_excluded = true)::numeric AS reported_excluded_bc_count,
    COUNT(*) FILTER (WHERE is_unclassified_pic = true)::numeric AS unclassified_pic_count,
    COUNT(*) FILTER (WHERE needs_manual_review_flag = true)::numeric AS manual_review_bc_count,
    AVG(unbilled_aging_days) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    )::numeric AS average_aging_open_bc
FROM snapshot.vw_latest_bc_daily_status_snapshot
GROUP BY
    snapshot_run_id,
    snapshot_date;

CREATE TEMP VIEW phase10_baseline_validation AS
SELECT
    metric_name,
    expected_value,
    actual_value,
    ABS(expected_value - actual_value) AS difference,
    tolerance,
    CASE
        WHEN ABS(expected_value - actual_value) <= tolerance THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM (
    SELECT 'total_bc_count' AS metric_name, e.total_bc_count AS expected_value, c.total_bc_count AS actual_value, 0::numeric AS tolerance FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'open_bc_count', e.open_bc_count, c.open_bc_count, 0::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'open_rab_exposure_amount', e.open_rab_exposure_amount, c.open_rab_exposure_amount, 0.01::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'high_risk_bc_count', e.high_risk_bc_count, c.high_risk_bc_count, 0::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'high_risk_rab_exposure_amount', e.high_risk_rab_exposure_amount, c.high_risk_rab_exposure_amount, 0.01::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'reported_excluded_bc_count', e.reported_excluded_bc_count, c.reported_excluded_bc_count, 0::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'unclassified_pic_count', e.unclassified_pic_count, c.unclassified_pic_count, 0::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'manual_review_bc_count', e.manual_review_bc_count, c.manual_review_bc_count, 0::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
    UNION ALL
    SELECT 'average_aging_open_bc', e.average_aging_open_bc, c.average_aging_open_bc, 0.000001::numeric FROM phase10_expected_baseline e CROSS JOIN phase10_control_kpi c
) validation_input;

CREATE TEMP VIEW phase10_reconciliation_validation AS
SELECT
    metric_name,
    control_value,
    recalculated_value,
    ABS(control_value - recalculated_value) AS difference,
    tolerance,
    CASE
        WHEN ABS(control_value - recalculated_value) <= tolerance THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM (
    SELECT 'total_bc_count' AS metric_name, c.total_bc_count AS control_value, r.total_bc_count AS recalculated_value, 0::numeric AS tolerance FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'open_bc_count', c.open_bc_count, r.open_bc_count, 0::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'open_rab_exposure_amount', c.open_rab_exposure_amount, r.open_rab_exposure_amount, 0.01::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'high_risk_bc_count', c.high_risk_bc_count, r.high_risk_bc_count, 0::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'high_risk_rab_exposure_amount', c.high_risk_rab_exposure_amount, r.high_risk_rab_exposure_amount, 0.01::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'reported_excluded_bc_count', c.reported_excluded_bc_count, r.reported_excluded_bc_count, 0::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'unclassified_pic_count', c.unclassified_pic_count, r.unclassified_pic_count, 0::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'manual_review_bc_count', c.manual_review_bc_count, r.manual_review_bc_count, 0::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
    UNION ALL
    SELECT 'average_aging_open_bc', c.average_aging_open_bc, r.average_aging_open_bc, 0.000001::numeric FROM phase10_control_kpi c CROSS JOIN phase10_recalculated_kpi r
) validation_input;

\echo 'A. Baseline validation: expected documented baseline vs KPI control view'

SELECT
    metric_name,
    expected_value,
    actual_value,
    difference,
    tolerance,
    validation_result
FROM phase10_baseline_validation
ORDER BY metric_name;

\echo 'B. Reconciliation validation: KPI control view vs recalculated latest snapshot fact'

SELECT
    metric_name,
    control_value,
    recalculated_value,
    difference,
    tolerance,
    validation_result
FROM phase10_reconciliation_validation
ORDER BY metric_name;

\echo 'C. Business rule validation controls'

SELECT
    'reported_exclusion_control' AS control_name,
    COUNT(*) FILTER (WHERE billing_status = 'REPORTED') AS total_reported_rows,
    COUNT(*) FILTER (
        WHERE billing_status = 'REPORTED'
          AND is_reported_excluded = true
    ) AS reported_excluded_rows,
    COUNT(*) FILTER (
        WHERE billing_status = 'REPORTED'
          AND is_open_unbilled = true
    ) AS reported_in_open_backlog_rows,
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

SELECT
    'average_aging_open_bc_control' AS control_name,
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    ) AS included_rows,
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ON GOING'
    ) AS open_ongoing_rows_excluded,
    COUNT(*) FILTER (
        WHERE is_open_unbilled = true
          AND unbilled_aging_days <= 0
    ) AS open_non_positive_aging_rows_excluded,
    AVG(unbilled_aging_days) FILTER (
        WHERE is_open_unbilled = true
          AND event_status = 'ENDED'
          AND unbilled_aging_days > 0
    ) AS recalculated_average_aging_open_bc,
    CASE
        WHEN AVG(unbilled_aging_days) FILTER (
            WHERE is_open_unbilled = true
              AND event_status = 'ENDED'
              AND unbilled_aging_days > 0
        ) IS NOT NULL
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot;

SELECT
    'daily_movement_readiness' AS control_name,
    COUNT(DISTINCT snapshot_date) AS distinct_snapshot_dates,
    CASE
        WHEN COUNT(DISTINCT snapshot_date) >= 2 THEN 'PASS'
        ELSE 'NEEDS REVIEW'
    END AS validation_result
FROM snapshot.bc_daily_status_snapshot;

\echo 'D. Final Phase 10 validation summary'

WITH final_summary AS (
    SELECT validation_result FROM phase10_baseline_validation
    UNION ALL
    SELECT validation_result FROM phase10_reconciliation_validation
)
SELECT
    COUNT(*) AS total_metric_checks,
    COUNT(*) FILTER (WHERE validation_result = 'PASS') AS passed_metric_checks,
    COUNT(*) FILTER (WHERE validation_result <> 'PASS') AS failed_metric_checks,
    CASE
        WHEN COUNT(*) FILTER (WHERE validation_result <> 'PASS') = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS phase10_validation_result,
    CASE
        WHEN COUNT(*) FILTER (WHERE validation_result <> 'PASS') = 0 THEN 'LOW'
        ELSE 'HIGH'
    END AS risk_level
FROM final_summary;
