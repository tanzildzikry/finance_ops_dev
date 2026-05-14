\set ON_ERROR_STOP on

\echo 'START Phase 9.3 - Execute First Snapshot'

\echo 'Running snapshot.run_bc_daily_snapshot...'

SELECT
    snapshot.run_bc_daily_snapshot(CURRENT_DATE, '1600_WIB', 'daily_csv_upload') AS snapshot_run_id;

\echo 'Snapshot run log latest result'

SELECT
    snapshot_run_id,
    snapshot_date,
    snapshot_cutoff_label,
    source_type,
    total_clean_bc_rows,
    total_snapshot_rows,
    total_issue_history_rows,
    snapshot_status,
    validation_result,
    risk_level,
    created_at,
    completed_at
FROM snapshot.snapshot_run_log
ORDER BY snapshot_run_id DESC
LIMIT 1;

\echo 'Snapshot row count validation'

WITH latest_run AS (
    SELECT snapshot_run_id
    FROM snapshot.snapshot_run_log
    ORDER BY snapshot_run_id DESC
    LIMIT 1
),
snapshot_validation AS (
    SELECT
        'snapshot.bc_daily_status_snapshot' AS table_name,
        COUNT(*) AS actual_row_count,
        8266 AS expected_row_count
    FROM snapshot.bc_daily_status_snapshot s
    JOIN latest_run lr
        ON s.snapshot_run_id = lr.snapshot_run_id

    UNION ALL

    SELECT
        'snapshot.bc_daily_issue_history' AS table_name,
        COUNT(*) AS actual_row_count,
        8266 AS expected_row_count
    FROM snapshot.bc_daily_issue_history h
    JOIN latest_run lr
        ON h.snapshot_run_id = lr.snapshot_run_id
)
SELECT
    table_name,
    actual_row_count,
    expected_row_count,
    CASE
        WHEN actual_row_count = expected_row_count THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot_validation
ORDER BY table_name;

\echo 'Latest snapshot of day validation'

WITH latest_run AS (
    SELECT snapshot_run_id, snapshot_date
    FROM snapshot.snapshot_run_log
    ORDER BY snapshot_run_id DESC
    LIMIT 1
)
SELECT
    s.snapshot_date,
    COUNT(*) AS latest_snapshot_rows,
    COUNT(*) FILTER (WHERE s.is_latest_snapshot_of_day = true) AS latest_flag_true_count,
    CASE
        WHEN COUNT(*) = 8266
         AND COUNT(*) FILTER (WHERE s.is_latest_snapshot_of_day = true) = 8266
        THEN 'PASS'
        ELSE 'NEEDS REVIEW'
    END AS validation_result
FROM snapshot.bc_daily_status_snapshot s
JOIN latest_run lr
    ON s.snapshot_run_id = lr.snapshot_run_id
GROUP BY s.snapshot_date;

\echo 'END Phase 9.3 - Execute First Snapshot'
