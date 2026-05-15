
/*
Finance_Ops_Dev - Phase 12 Semantic Model Validation
Generated: 2026-05-15

Purpose:
- Validate reporting schema curated views before Power BI load.
- Validate grain, key uniqueness, orphan keys, control table row counts,
  and movement readiness.

Validation Result:
- PASS only when all blocking checks return PASS.
- Movement can be PASS STRUCTURE ONLY when distinct_snapshot_dates < 2.

Run after:
    01_database/sql/phase_12_reporting_views.sql
*/

-- ---------------------------------------------------------------------------
-- 1. Source / reporting object existence
-- ---------------------------------------------------------------------------

WITH required_objects AS (
    SELECT 'reporting.fact_current_bc' AS object_name UNION ALL
    SELECT 'reporting.fact_movement_bc' UNION ALL
    SELECT 'reporting.fact_issue_current' UNION ALL
    SELECT 'reporting.control_current_kpi' UNION ALL
    SELECT 'reporting.control_movement_kpi' UNION ALL
    SELECT 'reporting.dim_pic' UNION ALL
    SELECT 'reporting.dim_bc' UNION ALL
    SELECT 'reporting.dim_date'
),
object_check AS (
    SELECT
        r.object_name,
        CASE
            WHEN to_regclass(r.object_name) IS NOT NULL THEN 'PASS'
            ELSE 'BLOCKED'
        END AS validation_result
    FROM required_objects r
)
SELECT
    'OBJECT_EXISTENCE' AS test_group,
    object_name AS test_name,
    validation_result
FROM object_check
ORDER BY object_name;

-- ---------------------------------------------------------------------------
-- 2. Grain and key validation summary
-- ---------------------------------------------------------------------------

WITH fact_current AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT bc_number) AS distinct_bc_number,
        COUNT(*) FILTER (WHERE bc_number IS NULL OR TRIM(bc_number) = '') AS null_or_blank_bc_number,
        COUNT(*) - COUNT(DISTINCT bc_number) AS duplicate_bc_number
    FROM reporting.fact_current_bc
),
fact_movement AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT (snapshot_date, bc_number)) AS distinct_snapshot_date_bc_number,
        COUNT(*) FILTER (WHERE snapshot_date IS NULL) AS null_snapshot_date,
        COUNT(*) FILTER (WHERE bc_number IS NULL OR TRIM(bc_number) = '') AS null_or_blank_bc_number,
        COUNT(*) - COUNT(DISTINCT (snapshot_date, bc_number)) AS duplicate_snapshot_date_bc_number,
        COUNT(DISTINCT snapshot_date) AS distinct_snapshot_dates
    FROM reporting.fact_movement_bc
),
dim_pic AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT pic_code) AS distinct_pic_code,
        COUNT(*) FILTER (WHERE pic_code IS NULL OR TRIM(pic_code) = '') AS null_or_blank_pic_code,
        COUNT(*) - COUNT(DISTINCT pic_code) AS duplicate_pic_code,
        COUNT(*) FILTER (WHERE pic_code = 'UNCLASSIFIED') AS unclassified_row_count
    FROM reporting.dim_pic
),
dim_bc AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT bc_number) AS distinct_bc_number,
        COUNT(*) FILTER (WHERE bc_number IS NULL OR TRIM(bc_number) = '') AS null_or_blank_bc_number,
        COUNT(*) - COUNT(DISTINCT bc_number) AS duplicate_bc_number
    FROM reporting.dim_bc
),
dim_date AS (
    SELECT
        COUNT(*) AS row_count,
        COUNT(DISTINCT date) AS distinct_date,
        COUNT(*) FILTER (WHERE date IS NULL) AS null_date,
        COUNT(*) - COUNT(DISTINCT date) AS duplicate_date
    FROM reporting.dim_date
)
SELECT
    'GRAIN_VALIDATION' AS test_group,
    'Fact_Current_BC one row per bc_number' AS test_name,
    row_count,
    distinct_bc_number AS distinct_key_count,
    duplicate_bc_number AS duplicate_key_count,
    null_or_blank_bc_number AS null_key_count,
    CASE
        WHEN null_or_blank_bc_number > 0 THEN 'NEEDS REVISION'
        WHEN duplicate_bc_number > 0 THEN 'NEEDS REVISION'
        ELSE 'PASS'
    END AS validation_result
FROM fact_current

UNION ALL

SELECT
    'GRAIN_VALIDATION',
    'Fact_Movement_BC one row per snapshot_date + bc_number',
    row_count,
    distinct_snapshot_date_bc_number,
    duplicate_snapshot_date_bc_number,
    null_or_blank_bc_number + null_snapshot_date,
    CASE
        WHEN null_snapshot_date > 0 THEN 'NEEDS REVISION'
        WHEN null_or_blank_bc_number > 0 THEN 'NEEDS REVISION'
        WHEN duplicate_snapshot_date_bc_number > 0 THEN 'NEEDS REVISION'
        WHEN distinct_snapshot_dates < 2 THEN 'PASS STRUCTURE ONLY - MOVEMENT TREND NOT MEANINGFUL YET'
        ELSE 'PASS'
    END
FROM fact_movement

UNION ALL

SELECT
    'GRAIN_VALIDATION',
    'Dim_PIC one row per pic_code',
    row_count,
    distinct_pic_code,
    duplicate_pic_code,
    null_or_blank_pic_code,
    CASE
        WHEN null_or_blank_pic_code > 0 THEN 'NEEDS REVISION'
        WHEN duplicate_pic_code > 0 THEN 'NEEDS REVISION'
        WHEN unclassified_row_count = 0 THEN 'NEEDS REVIEW - UNCLASSIFIED PIC row missing'
        ELSE 'PASS'
    END
FROM dim_pic

UNION ALL

SELECT
    'GRAIN_VALIDATION',
    'Dim_BC one row per bc_number',
    row_count,
    distinct_bc_number,
    duplicate_bc_number,
    null_or_blank_bc_number,
    CASE
        WHEN null_or_blank_bc_number > 0 THEN 'NEEDS REVISION'
        WHEN duplicate_bc_number > 0 THEN 'NEEDS REVISION'
        ELSE 'PASS'
    END
FROM dim_bc

UNION ALL

SELECT
    'GRAIN_VALIDATION',
    'Dim_Date one row per date',
    row_count,
    distinct_date,
    duplicate_date,
    null_date,
    CASE
        WHEN null_date > 0 THEN 'NEEDS REVISION'
        WHEN duplicate_date > 0 THEN 'NEEDS REVISION'
        ELSE 'PASS'
    END
FROM dim_date;

-- ---------------------------------------------------------------------------
-- 3. Relationship orphan validation
-- ---------------------------------------------------------------------------

WITH current_pic_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_current_bc f
    LEFT JOIN reporting.dim_pic p
        ON f.pic_internal_code = p.pic_code
    WHERE p.pic_code IS NULL
),
movement_pic_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_movement_bc f
    LEFT JOIN reporting.dim_pic p
        ON f.pic_internal_code = p.pic_code
    WHERE p.pic_code IS NULL
),
current_bc_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_current_bc f
    LEFT JOIN reporting.dim_bc b
        ON f.bc_number = b.bc_number
    WHERE b.bc_number IS NULL
),
movement_bc_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_movement_bc f
    LEFT JOIN reporting.dim_bc b
        ON f.bc_number = b.bc_number
    WHERE b.bc_number IS NULL
),
issue_bc_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_issue_current f
    LEFT JOIN reporting.dim_bc b
        ON f.bc_number = b.bc_number
    WHERE b.bc_number IS NULL
),
movement_date_orphan AS (
    SELECT
        COUNT(*) AS orphan_count
    FROM reporting.fact_movement_bc f
    LEFT JOIN reporting.dim_date d
        ON f.snapshot_date = d.date
    WHERE d.date IS NULL
)
SELECT
    'ORPHAN_VALIDATION' AS test_group,
    'Fact_Current_BC pic_internal_code -> Dim_PIC pic_code' AS test_name,
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVIEW' END AS validation_result
FROM current_pic_orphan

UNION ALL

SELECT
    'ORPHAN_VALIDATION',
    'Fact_Movement_BC pic_internal_code -> Dim_PIC pic_code',
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVIEW' END
FROM movement_pic_orphan

UNION ALL

SELECT
    'ORPHAN_VALIDATION',
    'Fact_Current_BC bc_number -> Dim_BC bc_number',
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVISION' END
FROM current_bc_orphan

UNION ALL

SELECT
    'ORPHAN_VALIDATION',
    'Fact_Movement_BC bc_number -> Dim_BC bc_number',
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVISION' END
FROM movement_bc_orphan

UNION ALL

SELECT
    'ORPHAN_VALIDATION',
    'Fact_Issue_Current bc_number -> Dim_BC bc_number',
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVISION' END
FROM issue_bc_orphan

UNION ALL

SELECT
    'ORPHAN_VALIDATION',
    'Fact_Movement_BC snapshot_date -> Dim_Date date',
    orphan_count,
    CASE WHEN orphan_count = 0 THEN 'PASS' ELSE 'NEEDS REVISION' END
FROM movement_date_orphan;

-- ---------------------------------------------------------------------------
-- 4. KPI reconciliation baseline from reporting control view
-- ---------------------------------------------------------------------------

SELECT
    'CONTROL_CURRENT_KPI_BASELINE' AS test_group,
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
FROM reporting.control_current_kpi;

-- ---------------------------------------------------------------------------
-- 5. Current fact KPI vs control KPI reconciliation
-- ---------------------------------------------------------------------------

WITH current_fact_kpi AS (
    SELECT
        COUNT(*) AS total_bc_count,
        COUNT(*) FILTER (WHERE is_open_unbilled = TRUE) AS open_bc_count,
        SUM(open_rab_exposure_amount) AS open_rab_exposure_amount,
        COUNT(*) FILTER (WHERE high_risk_flag = TRUE) AS high_risk_bc_count,
        SUM(open_rab_exposure_amount) FILTER (WHERE high_risk_flag = TRUE) AS high_risk_rab_exposure_amount,
        COUNT(*) FILTER (WHERE is_reported_excluded = TRUE) AS reported_excluded_bc_count,
        COUNT(*) FILTER (WHERE is_unclassified_pic = TRUE) AS unclassified_pic_count,
        COUNT(*) FILTER (WHERE needs_manual_review_flag = TRUE) AS manual_review_bc_count,
        AVG(unbilled_aging_days) FILTER (
            WHERE is_open_unbilled = TRUE
              AND event_status = 'ENDED'
              AND unbilled_aging_days > 0
        ) AS average_aging_open_bc
    FROM reporting.fact_current_bc
),
control_kpi AS (
    SELECT
        total_bc_count,
        open_bc_count,
        open_rab_exposure_amount,
        high_risk_bc_count,
        high_risk_rab_exposure_amount,
        reported_excluded_bc_count,
        unclassified_pic_count,
        manual_review_bc_count,
        average_aging_open_bc
    FROM reporting.control_current_kpi
)
SELECT
    'CURRENT_VS_CONTROL_RECONCILIATION' AS test_group,
    f.total_bc_count - c.total_bc_count AS total_bc_diff,
    f.open_bc_count - c.open_bc_count AS open_bc_diff,
    f.open_rab_exposure_amount - c.open_rab_exposure_amount AS open_rab_exposure_diff,
    f.high_risk_bc_count - c.high_risk_bc_count AS high_risk_bc_diff,
    f.high_risk_rab_exposure_amount - c.high_risk_rab_exposure_amount AS high_risk_rab_exposure_diff,
    f.reported_excluded_bc_count - c.reported_excluded_bc_count AS reported_excluded_bc_diff,
    f.unclassified_pic_count - c.unclassified_pic_count AS unclassified_pic_diff,
    f.manual_review_bc_count - c.manual_review_bc_count AS manual_review_bc_diff,
    f.average_aging_open_bc - c.average_aging_open_bc AS average_aging_open_bc_diff,
    CASE
        WHEN f.total_bc_count - c.total_bc_count <> 0 THEN 'NEEDS REVISION'
        WHEN f.open_bc_count - c.open_bc_count <> 0 THEN 'NEEDS REVISION'
        WHEN ABS(f.open_rab_exposure_amount - c.open_rab_exposure_amount) > 1 THEN 'NEEDS REVISION'
        WHEN f.high_risk_bc_count - c.high_risk_bc_count <> 0 THEN 'NEEDS REVISION'
        WHEN ABS(f.high_risk_rab_exposure_amount - c.high_risk_rab_exposure_amount) > 1 THEN 'NEEDS REVISION'
        WHEN f.reported_excluded_bc_count - c.reported_excluded_bc_count <> 0 THEN 'NEEDS REVISION'
        WHEN f.unclassified_pic_count - c.unclassified_pic_count <> 0 THEN 'NEEDS REVISION'
        WHEN f.manual_review_bc_count - c.manual_review_bc_count <> 0 THEN 'NEEDS REVISION'
        WHEN ABS(f.average_aging_open_bc - c.average_aging_open_bc) > 0.0001 THEN 'NEEDS REVISION'
        ELSE 'PASS'
    END AS validation_result
FROM current_fact_kpi f
CROSS JOIN control_kpi c;

-- ---------------------------------------------------------------------------
-- 6. Movement readiness
-- ---------------------------------------------------------------------------

SELECT
    'MOVEMENT_READINESS' AS test_group,
    COUNT(DISTINCT snapshot_date) AS distinct_snapshot_dates,
    CASE
        WHEN COUNT(DISTINCT snapshot_date) >= 2 THEN 'PASS - MOVEMENT TREND CAN BE INTERPRETED'
        ELSE 'PASS STRUCTURE ONLY - NEED AT LEAST 2 LATEST-PER-DAY SNAPSHOT DATES'
    END AS validation_result
FROM reporting.fact_movement_bc;

-- ---------------------------------------------------------------------------
-- End of Phase 12 semantic model validation.
-- ---------------------------------------------------------------------------
