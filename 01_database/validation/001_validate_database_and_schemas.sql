/*
===============================================================================
Finance_Ops_Dev - Database and Schema Validation
File: 01_database/validation/001_validate_database_and_schemas.sql

Purpose:
- Validate that the project database exists
- Validate that required schemas exist
- Validate schema count
- Provide clear PASS / NEEDS REVISION result for Phase 3 foundation

Expected database:
- finance_ops_dev

Expected schemas:
- raw
- clean
- snapshot
- mart
- reporting
- documentary

Validation Result:
- PASS if all required schemas exist
- NEEDS REVISION if any required schema is missing
===============================================================================
*/


-- =============================================================================
-- VALIDATION 1: Confirm current database
-- =============================================================================

SELECT
    current_database() AS current_database_name;


-- =============================================================================
-- VALIDATION 2: Check required schema existence
-- =============================================================================

WITH required_schemas AS (
    SELECT 'raw' AS schema_name
    UNION ALL SELECT 'clean'
    UNION ALL SELECT 'snapshot'
    UNION ALL SELECT 'mart'
    UNION ALL SELECT 'reporting'
    UNION ALL SELECT 'documentary'
),
actual_schemas AS (
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
)
SELECT
    r.schema_name,
    CASE
        WHEN a.schema_name IS NOT NULL THEN 'PASS'
        ELSE 'MISSING'
    END AS schema_validation_status
FROM required_schemas r
LEFT JOIN actual_schemas a
    ON r.schema_name = a.schema_name
ORDER BY r.schema_name;


-- =============================================================================
-- VALIDATION 3: Required schema count
-- =============================================================================

SELECT
    COUNT(*) AS actual_required_schema_count,
    6 AS expected_required_schema_count,
    CASE
        WHEN COUNT(*) = 6 THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS schema_count_validation_result
FROM information_schema.schemata
WHERE schema_name IN (
    'raw',
    'clean',
    'snapshot',
    'mart',
    'reporting',
    'documentary'
);


-- =============================================================================
-- VALIDATION 4: Final Phase 3 foundation validation result
-- =============================================================================

WITH required_schemas AS (
    SELECT 'raw' AS schema_name
    UNION ALL SELECT 'clean'
    UNION ALL SELECT 'snapshot'
    UNION ALL SELECT 'mart'
    UNION ALL SELECT 'reporting'
    UNION ALL SELECT 'documentary'
),
actual_schemas AS (
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
),
validation_summary AS (
    SELECT
        COUNT(a.schema_name) AS existing_schema_count,
        COUNT(r.schema_name) AS expected_schema_count
    FROM required_schemas r
    LEFT JOIN actual_schemas a
        ON r.schema_name = a.schema_name
)
SELECT
    existing_schema_count,
    expected_schema_count,
    CASE
        WHEN existing_schema_count = expected_schema_count THEN 'PASS'
        ELSE 'NEEDS REVISION'
    END AS final_phase_3_database_foundation_result
FROM validation_summary;