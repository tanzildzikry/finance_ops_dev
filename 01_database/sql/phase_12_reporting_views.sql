
/*
Finance_Ops_Dev - Phase 12 Reporting Views
Generated: 2026-05-15

Purpose:
- Create curated reporting views for Power BI semantic model.
- Expose only approved Fact, Dim, and Control objects.
- Keep backend raw/clean/snapshot tables out of main PBIX model.
- Keep KPI control views disconnected in Power BI.

Validation Result:
- NEEDS REVIEW until executed in PostgreSQL and reconciled in Power BI.

Important:
- This script assumes Phase 11.3 approved source views already exist:
  - snapshot.vw_latest_bc_daily_status_snapshot
  - snapshot.vw_latest_snapshot_kpi_control
  - snapshot.vw_daily_status_snapshot_latest_per_day
  - snapshot.vw_daily_kpi_control_latest_per_day
  - snapshot.vw_latest_bc_daily_issue_history
  - clean.clean_pic_list
*/

CREATE SCHEMA IF NOT EXISTS reporting;

-- ---------------------------------------------------------------------------
-- 1. Current/latest dashboard fact
-- Grain: one row per bc_number for the latest snapshot.
-- Power BI display name: Fact_Current_BC
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.fact_current_bc AS
SELECT
    snapshot_run_id,
    snapshot_date,
    bc_number,
    pic_internal_code,
    customer_name,
    event_category,
    event_status,
    billing_status,
    bc_closing_status,
    invoice_number,
    event_start_date,
    event_end_date,
    latest_invoice_date,
    rab_budget_amount,
    total_invoiced_amount,
    invoice_completion_ratio,
    open_rab_exposure_amount,
    unbilled_aging_days,
    aging_bucket,
    closing_duration_days,
    risk_level,
    high_risk_flag,
    urgent_flag,
    is_open_unbilled,
    is_reported_excluded,
    is_unclassified_pic,
    needs_manual_review_flag,
    data_quality_flag,
    detected_issue_category,
    detected_blocker,
    responsibility_type,
    issue_source_text
FROM snapshot.vw_latest_bc_daily_status_snapshot;

COMMENT ON VIEW reporting.fact_current_bc IS
'Phase 12 Power BI current/latest dashboard fact. Grain: one row per BC latest snapshot.';

-- ---------------------------------------------------------------------------
-- 2. Movement fact
-- Grain: one row per snapshot_date + bc_number from latest run of each day.
-- Power BI display name: Fact_Movement_BC
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.fact_movement_bc AS
SELECT
    snapshot_run_id,
    snapshot_date,
    bc_number,
    pic_internal_code,
    customer_name,
    event_category,
    event_status,
    billing_status,
    bc_closing_status,
    invoice_number,
    event_start_date,
    event_end_date,
    latest_invoice_date,
    rab_budget_amount,
    total_invoiced_amount,
    invoice_completion_ratio,
    open_rab_exposure_amount,
    unbilled_aging_days,
    aging_bucket,
    closing_duration_days,
    risk_level,
    high_risk_flag,
    urgent_flag,
    is_open_unbilled,
    is_reported_excluded,
    is_unclassified_pic,
    needs_manual_review_flag,
    data_quality_flag,
    detected_issue_category,
    detected_blocker,
    responsibility_type,
    issue_source_text
FROM snapshot.vw_daily_status_snapshot_latest_per_day;

COMMENT ON VIEW reporting.fact_movement_bc IS
'Phase 12 Power BI movement fact. Grain: one row per snapshot_date + BC from latest run of day. Trend meaningful only when distinct snapshot_date >= 2.';

-- ---------------------------------------------------------------------------
-- 3. Current issue drill-through fact
-- Grain: current/latest issue state by BC.
-- Power BI display name: Fact_Issue_Current
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.fact_issue_current AS
SELECT
    snapshot_run_id,
    snapshot_date,
    bc_number,
    pic_internal_code,
    detected_issue_category,
    detected_blocker,
    responsibility_type,
    issue_confidence_level,
    issue_keyword_matched,
    needs_manual_review_flag,
    classification_method,
    issue_source_text,
    billing_remarks,
    document_status_or_missing_notes,
    po_status_or_po_number,
    umk_status,
    event_status,
    billing_status
FROM snapshot.vw_latest_bc_daily_issue_history;

COMMENT ON VIEW reporting.fact_issue_current IS
'Phase 12 Power BI current issue drill-through fact. Use Dim_BC for relationship; do not relate fact-to-fact.';

-- ---------------------------------------------------------------------------
-- 4. Current KPI reconciliation control
-- Grain: one row for latest snapshot KPI control.
-- Power BI display name: Control_Current_KPI
-- Relationship rule: disconnected table.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.control_current_kpi AS
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

COMMENT ON VIEW reporting.control_current_kpi IS
'Phase 12 disconnected KPI reconciliation control for current/latest dashboard. Do not create relationships in Power BI.';

-- ---------------------------------------------------------------------------
-- 5. Movement KPI control
-- Grain: one row per snapshot_date latest run of day.
-- Power BI display name: Control_Movement_KPI
-- Relationship rule: disconnected table for control/reconciliation.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.control_movement_kpi AS
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
FROM snapshot.vw_daily_kpi_control_latest_per_day;

COMMENT ON VIEW reporting.control_movement_kpi IS
'Phase 12 disconnected movement KPI control. Do not use for trend interpretation until latest-per-day distinct snapshot dates >= 2.';

-- ---------------------------------------------------------------------------
-- 6. PIC dimension
-- Grain: one row per pic_code.
-- Power BI display name: Dim_PIC
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.dim_pic AS
SELECT
    pic_code,
    pic_full_name,
    division_code,
    pic_status,
    CASE
        WHEN pic_code = 'UNCLASSIFIED' THEN TRUE
        ELSE FALSE
    END AS is_unclassified_pic
FROM clean.clean_pic_list;

COMMENT ON VIEW reporting.dim_pic IS
'Phase 12 PIC dimension. Grain: one row per pic_code. UNCLASSIFIED is correction bucket, not PIC performance penalty.';

-- ---------------------------------------------------------------------------
-- 7. BC dimension / bridge
-- Grain: one row per bc_number across current, movement, and issue sources.
-- Power BI display name: Dim_BC
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.dim_bc AS
WITH bc_union AS (
    SELECT
        bc_number
    FROM reporting.fact_current_bc
    WHERE bc_number IS NOT NULL
      AND TRIM(bc_number) <> ''

    UNION

    SELECT
        bc_number
    FROM reporting.fact_movement_bc
    WHERE bc_number IS NOT NULL
      AND TRIM(bc_number) <> ''

    UNION

    SELECT
        bc_number
    FROM reporting.fact_issue_current
    WHERE bc_number IS NOT NULL
      AND TRIM(bc_number) <> ''
)
SELECT
    bc_number
FROM bc_union;

COMMENT ON VIEW reporting.dim_bc IS
'Phase 12 BC dimension / bridge. Grain: one row per bc_number. Use for BC drill-through and issue relationship.';

-- ---------------------------------------------------------------------------
-- 8. Date dimension
-- Grain: one row per date.
-- Power BI display name: Dim_Date
--
-- Design note:
-- - Active relationship should be Dim_Date[date] -> Fact_Movement_BC[snapshot_date].
-- - Avoid active Dim_Date -> Fact_Current_BC because current fact is latest-only.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW reporting.dim_date AS
WITH date_bounds AS (
    SELECT
        MIN(snapshot_date)::date AS min_date,
        MAX(snapshot_date)::date AS max_date
    FROM reporting.fact_movement_bc
),
date_series AS (
    SELECT
        generate_series(
            COALESCE((SELECT min_date FROM date_bounds), CURRENT_DATE),
            COALESCE((SELECT max_date FROM date_bounds), CURRENT_DATE),
            INTERVAL '1 day'
        )::date AS date
)
SELECT
    date,
    EXTRACT(YEAR FROM date)::integer AS year,
    EXTRACT(QUARTER FROM date)::integer AS quarter,
    EXTRACT(MONTH FROM date)::integer AS month_number,
    TO_CHAR(date, 'Mon') AS month_name,
    TO_CHAR(date, 'YYYY-MM') AS year_month,
    EXTRACT(DAY FROM date)::integer AS day_of_month,
    EXTRACT(ISODOW FROM date)::integer AS iso_day_of_week,
    TO_CHAR(date, 'Dy') AS day_name,
    CASE
        WHEN EXTRACT(ISODOW FROM date) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM date_series;

COMMENT ON VIEW reporting.dim_date IS
'Phase 12 date dimension. Recommended active relationship only to movement fact snapshot_date.';

-- ---------------------------------------------------------------------------
-- End of Phase 12 reporting views.
-- ---------------------------------------------------------------------------
