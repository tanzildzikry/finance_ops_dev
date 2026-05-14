\set ON_ERROR_STOP on
\pset pager off

\echo 'PHASE 11 - POWER BI SOURCE READINESS VALIDATION'
\echo 'Purpose: validate PostgreSQL views/tables before Power BI semantic model connection.'

DROP VIEW IF EXISTS phase11_required_objects;
DROP VIEW IF EXISTS phase11_required_columns;
DROP VIEW IF EXISTS phase11_object_validation;
DROP VIEW IF EXISTS phase11_column_validation;
DROP VIEW IF EXISTS phase11_rowcount_validation;
DROP VIEW IF EXISTS phase11_key_validation;
DROP VIEW IF EXISTS phase11_pic_relationship_validation;
DROP VIEW IF EXISTS phase11_final_summary;

CREATE TEMP VIEW phase11_required_objects AS
SELECT *
FROM (
    VALUES
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'VIEW'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'VIEW'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'VIEW'),
        ('snapshot', 'bc_daily_status_snapshot', 'BASE TABLE'),
        ('clean', 'clean_pic_list', 'BASE TABLE')
) AS required(schema_name, object_name, expected_table_type);

CREATE TEMP VIEW phase11_required_columns AS
SELECT *
FROM (
    VALUES
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'snapshot_run_id'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'snapshot_date'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'bc_number'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'event_name'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'customer_name'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'pic_internal_code'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'event_category'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'event_status'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'billing_status'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'unbilled_aging_days'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'aging_bucket'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'rab_budget_amount'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'total_invoiced_amount'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'open_rab_exposure_amount'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'invoice_completion_ratio'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'invoice_completion_bucket'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'bc_closing_status'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'is_open_unbilled'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'is_reported_excluded'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'is_unclassified_pic'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'high_risk_flag'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'needs_manual_review_flag'),
        ('snapshot', 'vw_latest_bc_daily_status_snapshot', 'issue_source_text'),

        ('snapshot', 'vw_latest_snapshot_kpi_control', 'snapshot_run_id'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'snapshot_date'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'total_bc_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'open_bc_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'open_rab_exposure_amount'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'high_risk_bc_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'high_risk_rab_exposure_amount'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'reported_excluded_bc_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'unclassified_pic_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'manual_review_bc_count'),
        ('snapshot', 'vw_latest_snapshot_kpi_control', 'average_aging_open_bc'),

        ('snapshot', 'vw_latest_bc_daily_issue_history', 'snapshot_run_id'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'snapshot_date'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'bc_number'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'issue_source_text'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'detected_issue_category'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'detected_blocker'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'responsibility_type'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'issue_confidence_level'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'classification_method'),
        ('snapshot', 'vw_latest_bc_daily_issue_history', 'needs_manual_review_flag'),

        ('snapshot', 'bc_daily_status_snapshot', 'snapshot_run_id'),
        ('snapshot', 'bc_daily_status_snapshot', 'snapshot_date'),
        ('snapshot', 'bc_daily_status_snapshot', 'bc_number'),
        ('snapshot', 'bc_daily_status_snapshot', 'pic_internal_code'),
        ('snapshot', 'bc_daily_status_snapshot', 'is_open_unbilled'),
        ('snapshot', 'bc_daily_status_snapshot', 'open_rab_exposure_amount'),
        ('snapshot', 'bc_daily_status_snapshot', 'high_risk_flag'),

        ('clean', 'clean_pic_list', 'pic_code')
) AS required(table_schema, table_name, column_name);

CREATE TEMP VIEW phase11_object_validation AS
SELECT
    r.schema_name,
    r.object_name,
    r.expected_table_type,
    COALESCE(t.table_type, 'MISSING') AS actual_table_type,
    CASE
        WHEN t.table_schema IS NOT NULL
         AND t.table_type = r.expected_table_type
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM phase11_required_objects r
LEFT JOIN information_schema.tables t
    ON t.table_schema = r.schema_name
   AND t.table_name = r.object_name;

CREATE TEMP VIEW phase11_column_validation AS
SELECT
    r.table_schema,
    r.table_name,
    r.column_name,
    CASE
        WHEN c.column_name IS NOT NULL THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM phase11_required_columns r
LEFT JOIN information_schema.columns c
    ON c.table_schema = r.table_schema
   AND c.table_name = r.table_name
   AND c.column_name = r.column_name;

CREATE TEMP VIEW phase11_rowcount_validation AS
SELECT
    'latest_status_vs_kpi_total_bc' AS control_name,
    k.total_bc_count::bigint AS expected_count,
    COUNT(s.bc_number)::bigint AS actual_count,
    CASE
        WHEN COUNT(s.bc_number)::bigint = k.total_bc_count::bigint THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_snapshot_kpi_control k
CROSS JOIN snapshot.vw_latest_bc_daily_status_snapshot s
GROUP BY
    k.total_bc_count

UNION ALL

SELECT
    'latest_issue_history_vs_kpi_total_bc' AS control_name,
    k.total_bc_count::bigint AS expected_count,
    COUNT(i.bc_number)::bigint AS actual_count,
    CASE
        WHEN COUNT(i.bc_number)::bigint = k.total_bc_count::bigint THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_snapshot_kpi_control k
CROSS JOIN snapshot.vw_latest_bc_daily_issue_history i
GROUP BY
    k.total_bc_count

UNION ALL

SELECT
    'kpi_control_single_row' AS control_name,
    1::bigint AS expected_count,
    COUNT(*)::bigint AS actual_count,
    CASE
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_snapshot_kpi_control

UNION ALL

SELECT
    'pic_dimension_non_empty' AS control_name,
    1::bigint AS expected_count,
    COUNT(*)::bigint AS actual_count,
    CASE
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM clean.clean_pic_list;

CREATE TEMP VIEW phase11_key_validation AS
SELECT
    'latest_status_bc_key_not_null' AS control_name,
    COUNT(*) FILTER (
        WHERE bc_number IS NULL
           OR TRIM(bc_number) = ''
    )::bigint AS issue_count,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE bc_number IS NULL
               OR TRIM(bc_number) = ''
        ) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot

UNION ALL

SELECT
    'latest_status_bc_key_unique' AS control_name,
    COUNT(*)::bigint - COUNT(DISTINCT bc_number)::bigint AS issue_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT bc_number) THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot

UNION ALL

SELECT
    'latest_issue_history_bc_key_not_null' AS control_name,
    COUNT(*) FILTER (
        WHERE bc_number IS NULL
           OR TRIM(bc_number) = ''
    )::bigint AS issue_count,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE bc_number IS NULL
               OR TRIM(bc_number) = ''
        ) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_issue_history

UNION ALL

SELECT
    'latest_issue_history_bc_key_unique' AS control_name,
    COUNT(*)::bigint - COUNT(DISTINCT bc_number)::bigint AS issue_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT bc_number) THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_issue_history

UNION ALL

SELECT
    'snapshot_history_key_unique_by_run_and_bc' AS control_name,
    COALESCE(SUM(duplicate_count - 1), 0)::bigint AS issue_count,
    CASE
        WHEN COALESCE(SUM(duplicate_count - 1), 0) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM (
    SELECT
        snapshot_run_id,
        bc_number,
        COUNT(*) AS duplicate_count
    FROM snapshot.bc_daily_status_snapshot
    GROUP BY
        snapshot_run_id,
        bc_number
    HAVING COUNT(*) > 1
) duplicate_check;

CREATE TEMP VIEW phase11_pic_relationship_validation AS
SELECT
    'pic_relationship_orphan_excluding_unclassified' AS control_name,
    COUNT(*)::bigint AS issue_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot s
LEFT JOIN clean.clean_pic_list p
    ON s.pic_internal_code = p.pic_code
WHERE s.pic_internal_code IS NOT NULL
  AND TRIM(s.pic_internal_code) <> ''
  AND s.pic_internal_code <> 'UNCLASSIFIED'
  AND p.pic_code IS NULL;

CREATE TEMP VIEW phase11_final_summary AS
SELECT validation_result FROM phase11_object_validation
UNION ALL
SELECT validation_result FROM phase11_column_validation
UNION ALL
SELECT validation_result FROM phase11_rowcount_validation
UNION ALL
SELECT validation_result FROM phase11_key_validation
UNION ALL
SELECT validation_result FROM phase11_pic_relationship_validation;

\echo 'A. Required object validation'

SELECT
    schema_name,
    object_name,
    expected_table_type,
    actual_table_type,
    validation_result
FROM phase11_object_validation
ORDER BY
    schema_name,
    object_name;

\echo 'B. Required column validation'

SELECT
    table_schema,
    table_name,
    column_name,
    validation_result
FROM phase11_column_validation
ORDER BY
    table_schema,
    table_name,
    column_name;

\echo 'C. Row count validation'

SELECT
    control_name,
    expected_count,
    actual_count,
    validation_result
FROM phase11_rowcount_validation
ORDER BY
    control_name;

\echo 'D. Key validation'

SELECT
    control_name,
    issue_count,
    validation_result
FROM phase11_key_validation
ORDER BY
    control_name;

\echo 'E. PIC relationship validation'

SELECT
    control_name,
    issue_count,
    validation_result
FROM phase11_pic_relationship_validation;

\echo 'F. Power BI source readiness final summary'

SELECT
    COUNT(*) AS total_checks,
    COUNT(*) FILTER (WHERE validation_result = 'PASS') AS passed_checks,
    COUNT(*) FILTER (WHERE validation_result <> 'PASS') AS failed_checks,
    CASE
        WHEN COUNT(*) FILTER (WHERE validation_result <> 'PASS') = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS phase11_validation_result,
    CASE
        WHEN COUNT(*) FILTER (WHERE validation_result <> 'PASS') = 0 THEN 'LOW'
        ELSE 'HIGH'
    END AS risk_level
FROM phase11_final_summary;
