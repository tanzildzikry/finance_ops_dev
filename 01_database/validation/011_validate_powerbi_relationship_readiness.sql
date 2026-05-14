\set ON_ERROR_STOP on

\echo 'START Phase 11.2 - Power BI Relationship Readiness Validation'

\echo '1. FactCurrentBC bc_number uniqueness validation'

SELECT
    'snapshot.vw_latest_bc_daily_status_snapshot.bc_number' AS control_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT bc_number) AS distinct_bc_count,
    COUNT(*) - COUNT(DISTINCT bc_number) AS duplicate_bc_count,
    COUNT(*) FILTER (WHERE bc_number IS NULL OR btrim(bc_number) = '') AS null_or_blank_bc_count,
    CASE
        WHEN COUNT(*) = 8266
         AND COUNT(*) = COUNT(DISTINCT bc_number)
         AND COUNT(*) FILTER (WHERE bc_number IS NULL OR btrim(bc_number) = '') = 0
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot;

\echo '2. FactSnapshotDaily uniqueness by snapshot_date and bc_number validation'

WITH duplicate_check AS (
    SELECT
        snapshot_date,
        bc_number,
        COUNT(*) AS row_count
    FROM snapshot.vw_daily_status_snapshot_latest_per_day
    GROUP BY
        snapshot_date,
        bc_number
    HAVING COUNT(*) > 1
)
SELECT
    'snapshot.vw_daily_status_snapshot_latest_per_day(snapshot_date,bc_number)' AS control_name,
    (SELECT COUNT(*) FROM snapshot.vw_daily_status_snapshot_latest_per_day) AS total_row_count,
    COUNT(*) AS duplicate_key_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM duplicate_check;

\echo '3. DimPIC pic_code uniqueness validation'

SELECT
    'clean.clean_pic_list.pic_code' AS control_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT pic_code) AS distinct_pic_count,
    COUNT(*) - COUNT(DISTINCT pic_code) AS duplicate_pic_count,
    COUNT(*) FILTER (WHERE pic_code IS NULL OR btrim(pic_code) = '') AS null_or_blank_pic_count,
    CASE
        WHEN COUNT(*) = 69
         AND COUNT(*) = COUNT(DISTINCT pic_code)
         AND COUNT(*) FILTER (WHERE pic_code IS NULL OR btrim(pic_code) = '') = 0
        THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM clean.clean_pic_list;

\echo '4. PIC orphan validation excluding UNCLASSIFIED'

SELECT
    'FactCurrentBC to DimPIC orphan excluding UNCLASSIFIED' AS control_name,
    COUNT(*) AS orphan_pic_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS validation_result
FROM snapshot.vw_latest_bc_daily_status_snapshot f
LEFT JOIN clean.clean_pic_list p
    ON f.pic_internal_code = p.pic_code
WHERE f.pic_internal_code IS NOT NULL
  AND f.pic_internal_code <> 'UNCLASSIFIED'
  AND p.pic_code IS NULL;

\echo '5. Issue table BC uniqueness / relationship risk validation'

WITH issue_duplicate_check AS (
    SELECT
        bc_number,
        COUNT(*) AS row_count
    FROM snapshot.vw_latest_bc_daily_issue_history
    GROUP BY bc_number
    HAVING COUNT(*) > 1
)
SELECT
    'FactIssueCurrent.bc_number uniqueness' AS control_name,
    (SELECT COUNT(*) FROM snapshot.vw_latest_bc_daily_issue_history) AS issue_row_count,
    (SELECT COUNT(DISTINCT bc_number) FROM snapshot.vw_latest_bc_daily_issue_history) AS distinct_issue_bc_count,
    COUNT(*) AS duplicate_issue_bc_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'NEEDS REVIEW'
    END AS validation_result,
    CASE
        WHEN COUNT(*) = 0 THEN 'Current issue table is 1:1 by BC, but keep as drill-through/detail to avoid future fact-to-fact ambiguity.'
        ELSE 'Issue table has multiple rows per BC. Do not create active 1:1 relationship to FactCurrentBC.'
    END AS control_note
FROM issue_duplicate_check;

\echo '6. Latest-per-day movement source validation'

SELECT
    'daily latest movement source' AS control_name,
    COUNT(DISTINCT snapshot_date) AS snapshot_date_count,
    COUNT(*) AS total_row_count,
    COUNT(*) FILTER (WHERE is_latest_snapshot_of_day = true) AS latest_flag_true_count,
    CASE
        WHEN COUNT(*) > 0
         AND COUNT(*) FILTER (WHERE is_latest_snapshot_of_day = true) = COUNT(*)
        THEN 'PASS'
        ELSE 'NEEDS REVIEW'
    END AS validation_result
FROM snapshot.vw_daily_status_snapshot_latest_per_day;

\echo '7. Relationship readiness final summary'

WITH checks AS (
    SELECT
        'FactCurrentBC_bc_unique' AS check_name,
        CASE
            WHEN (
                SELECT COUNT(*) - COUNT(DISTINCT bc_number)
                FROM snapshot.vw_latest_bc_daily_status_snapshot
            ) = 0
            THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    UNION ALL
    SELECT
        'FactSnapshotDaily_snapshot_date_bc_unique' AS check_name,
        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM snapshot.vw_daily_status_snapshot_latest_per_day
                GROUP BY snapshot_date, bc_number
                HAVING COUNT(*) > 1
            )
            THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    UNION ALL
    SELECT
        'DimPIC_pic_code_unique' AS check_name,
        CASE
            WHEN (
                SELECT COUNT(*) - COUNT(DISTINCT pic_code)
                FROM clean.clean_pic_list
            ) = 0
            THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
    UNION ALL
    SELECT
        'PIC_orphan_excluding_UNCLASSIFIED' AS check_name,
        CASE
            WHEN (
                SELECT COUNT(*)
                FROM snapshot.vw_latest_bc_daily_status_snapshot f
                LEFT JOIN clean.clean_pic_list p
                    ON f.pic_internal_code = p.pic_code
                WHERE f.pic_internal_code IS NOT NULL
                  AND f.pic_internal_code <> 'UNCLASSIFIED'
                  AND p.pic_code IS NULL
            ) = 0
            THEN 'PASS'
            ELSE 'NEEDS REVISION'
        END AS validation_result
)
SELECT
    check_name,
    validation_result
FROM checks
ORDER BY check_name;

\echo 'END Phase 11.2 - Power BI Relationship Readiness Validation'
