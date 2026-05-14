# Phase 11 ? Power BI Connection / Semantic Model Preparation

Status: PASS  
Validation Date: 2026-05-15  
Risk Level: LOW  
Production Readiness: NOT YET  

## Purpose

Prepare approved PostgreSQL sources for Power BI connection and semantic model build.

This phase validates that Power BI can safely consume stable snapshot and clean-layer objects before DAX and visual development.

## Approved Power BI Source Objects

| Purpose | PostgreSQL Object | Power BI Role |
|---|---|---|
| Current dashboard fact | `snapshot.vw_latest_bc_daily_status_snapshot` | Main current-state fact |
| KPI reconciliation | `snapshot.vw_latest_snapshot_kpi_control` | SQL control / reconciliation table |
| Issue drill-through | `snapshot.vw_latest_bc_daily_issue_history` | Issue detail / investigation table |
| Daily movement / trend | `snapshot.bc_daily_status_snapshot` | Historical snapshot fact |
| PIC dimension | `clean.clean_pic_list` | PIC dimension |

## Recommended Initial Connection Mode

Import mode.

Reason:

- Dataset is small enough for development.
- Import mode gives better DAX performance and stable reconciliation.
- DirectQuery can be reviewed later only if refresh volume or governance requires it.

## Recommended Semantic Model Tables

### FactCurrentBC

Source: `snapshot.vw_latest_bc_daily_status_snapshot`

Grain: one row per BC in latest completed snapshot.

Business key: `bc_number`

Use: main fact table for Executive Overview, AR Controller, PIC Operation Scoring, and BC investigation.

### KpiSqlControl

Source: `snapshot.vw_latest_snapshot_kpi_control`

Grain: one row for latest completed PASS snapshot KPI control.

Use: SQL-vs-Power BI reconciliation only. Do not use as the main visual fact table.

### FactIssueCurrent

Source: `snapshot.vw_latest_bc_daily_issue_history`

Grain: one row per BC issue record in latest completed snapshot.

Use: issue drill-through and blocker investigation.

### FactSnapshotDaily

Source: `snapshot.bc_daily_status_snapshot`

Grain: one row per BC per snapshot run.

Use: daily movement and trend analysis.

Control: daily movement is meaningful because `distinct_snapshot_dates = 2` and validation result is PASS.

### DimPIC

Source: `clean.clean_pic_list`

Grain: one row per PIC code.

Use: PIC slicer, PIC labels, and relationship control.

## Recommended Relationships

| From | To | Cardinality | Filter Direction |
|---|---|---|---|
| `DimPIC[pic_code]` | `FactCurrentBC[pic_internal_code]` | One-to-many | Single |
| `DimPIC[pic_code]` | `FactSnapshotDaily[pic_internal_code]` | One-to-many | Single |
| `FactCurrentBC[bc_number]` | `FactIssueCurrent[bc_number]` | One-to-one or one-to-many | Single |

Relationship controls:

- Use single-direction relationships.
- Avoid bidirectional relationships unless there is a validated reason.
- Do not create many-to-many relationships for core KPI pages.

## Date Table Recommendation

Create a dedicated Power BI date table.

Recommended active relationships:

- `Date[Date]` to `FactCurrentBC[snapshot_date]`
- `Date[Date]` to `FactSnapshotDaily[snapshot_date]`

Optional inactive role-playing dates can be reviewed later for:

- `event_start_date`
- `event_end_date`
- `latest_invoice_date`

## Core DAX Strategy

Keep DAX simple and use snapshot-derived fields.

Recommended baseline measures:

```DAX
Total BC Count =
COUNTROWS('FactCurrentBC')

Open BC Count =
CALCULATE(
    COUNTROWS('FactCurrentBC'),
    'FactCurrentBC'[is_open_unbilled] = TRUE()
)

Open RAB Exposure =
SUM('FactCurrentBC'[open_rab_exposure_amount])

High Risk BC Count =
CALCULATE(
    COUNTROWS('FactCurrentBC'),
    'FactCurrentBC'[high_risk_flag] = TRUE()
)

High Risk RAB Exposure =
CALCULATE(
    [Open RAB Exposure],
    'FactCurrentBC'[high_risk_flag] = TRUE()
)
```

Avoid this as open backlog logic:

```DAX
billing_status <> "BILLED"
```

## KPI Reconciliation Baseline

Until a newer validated snapshot is run, Power BI cards must reconcile to:

- `total_bc_count = 8266`
- `open_bc_count = 8145`
- `open_rab_exposure_amount = 4,956,993,250,804.46`
- `high_risk_bc_count = 3`
- `high_risk_rab_exposure_amount = 23,820,974,461.00`
- `reported_excluded_bc_count = 112`
- `unclassified_pic_count = 12`
- `manual_review_bc_count = 20`
- `average_aging_open_bc = 51.0055248618784530`

## Phase 11 SQL Validation

Validation file:

`01_database/validation/011_validate_powerbi_source_readiness.sql`

Validation output:

- `total_checks = 67`
- `passed_checks = 67`
- `failed_checks = 0`
- `phase11_validation_result = PASS`
- `risk_level = LOW`

## Validation Result

PASS

## Risk Level

LOW

## Next Phase

Phase 12 ? Power BI Semantic Model Build / Relationship Setup

## Hold Point

Do not proceed to DAX or visual build until the Power BI model is connected and table/relationship setup is confirmed.
