# Phase 12 — Power BI Naming, Relationship, Measure, and Load Contract

**Project:** Finance_Ops_Dev  
**Phase:** Phase 12 — Power BI Semantic Model Build / Relationship Setup  
**Document Type:** Power BI Semantic Model Contract  
**Recommended File Name:** `phase_12_powerbi_naming_relationship_and_measure_contract.md`  
**Status:** ACTIVE CONTRACT  
**Validation Status:** NEEDS REVIEW until PBIX validation is completed  
**Risk Level:** MEDIUM before PBIX validation, LOW after all relationship and KPI reconciliation checks pass  

---

## 1. Purpose

This document defines the approved Power BI naming, relationship, control table, measure naming, canonical measure, DAX logic, column notes, and load rules for Phase 12.

This document is intended to prevent ambiguity when building the Power BI semantic model.

The main objectives are:

1. Use only curated PostgreSQL reporting views in Power BI.
2. Keep Power BI table names business-readable.
3. Prevent fact-to-fact relationships.
4. Prevent bidirectional and uncontrolled many-to-many relationships.
5. Keep control tables disconnected.
6. Keep DAX measures canonical and minimal.
7. Ensure breakdown by PIC, customer, BC, division, and date comes from dimension filter context, not duplicated measures.
8. Prevent misuse of movement data before movement is meaningful.
9. Prevent use of raw, clean, or base snapshot tables in the main PBIX model.

---

## 2. Power BI Table Naming Mapping

Use the following table naming convention in Power BI.

| PostgreSQL Source | Power BI Table Name | Role |
|---|---|---|
| `reporting.fact_current_bc` | `Fact_Current_BC` | Current/latest dashboard fact |
| `reporting.fact_movement_bc` | `Fact_Movement_BC` | Movement/trend fact |
| `reporting.fact_issue_current` | `Fact_Issue_Current` | Issue drill-through/detail |
| `reporting.control_current_kpi` | `Control_Current_KPI` | Disconnected current KPI reconciliation |
| `reporting.control_movement_kpi` | `Control_Movement_KPI` | Disconnected movement KPI control |
| `reporting.dim_pic` | `Dim_PIC` | PIC dimension |
| `reporting.dim_bc` | `Dim_BC` | BC dimension / bridge |
| `reporting.dim_date` | `Dim_Date` | Date dimension |
| DAX-only table | `_Measures` | Measure container |

---

## 3. Power BI Relationship Mapping

Create only the relationships listed below.

| From | To | Cardinality | Direction | Active |
|---|---|---|---|---|
| `Dim_PIC[pic_code]` | `Fact_Current_BC[pic_internal_code]` | `1:*` | Single | Yes |
| `Dim_PIC[pic_code]` | `Fact_Movement_BC[pic_internal_code]` | `1:*` | Single | Yes |
| `Dim_BC[bc_number]` | `Fact_Current_BC[bc_number]` | `1:*` | Single | Yes |
| `Dim_BC[bc_number]` | `Fact_Movement_BC[bc_number]` | `1:*` | Single | Yes |
| `Dim_BC[bc_number]` | `Fact_Issue_Current[bc_number]` | `1:*` | Single | Yes |
| `Dim_Date[date]` | `Fact_Movement_BC[snapshot_date]` | `1:*` | Single | Yes |

---

## 4. Relationship Rules

Do not create relationships outside the approved relationship mapping.

The following are not allowed:

1. Fact-to-fact relationship.
2. Control table relationship.
3. Bidirectional filter.
4. Uncontrolled many-to-many relationship.
5. Active `Dim_Date` relationship to `Fact_Current_BC`.

---

## 5. Control Table Rule

The following tables must remain disconnected:

```text
Control_Current_KPI
Control_Movement_KPI
```

These tables are used only for reconciliation and control baseline.

They must not be used as filtering dimensions.

Control tables should not be connected to:

1. Fact tables.
2. Dimension tables.
3. Other control tables.

---

## 6. Measure Naming Convention

Use strict measure prefixes.

| Prefix | Function |
|---|---|
| `Current ...` | KPI from `Fact_Current_BC` |
| `Control ...` | KPI baseline from `Control_Current_KPI` |
| `Recon ...` | Difference between current KPI and control KPI |
| `Movement ...` | Guardrail / movement measures |

---

## 7. Forbidden Measure Naming Pattern

Do not create measure variants that duplicate dimension filter context.

Do not create measures such as:

```text
Open BC Count by PIC
Open RAB Exposure by PIC
PIC Open RAB Exposure
Open BC by Customer
Open Exposure by Division
Total Open Backlog
Unbilled Amount
Open RAB
```

Breakdown by PIC, customer, division, BC, or date must come from dimension filter context.

Examples:

1. PIC breakdown must come from `Dim_PIC`.
2. BC breakdown must come from `Dim_BC`.
3. Movement date breakdown must come from `Dim_Date`.
4. Issue drill-through must use `Dim_BC` filter path.

---

## 8. Canonical Measure List

Only the following canonical measures should be created for Phase 12 baseline.

Additional measures require explicit review before being added.

### 8.1 Current KPI Measures

| Measure Name | Source Table | Purpose |
|---|---|---|
| `Current Total BC Count` | `Fact_Current_BC` | Count all current BC rows |
| `Current Open BC Count` | `Fact_Current_BC` | Count open unbilled BC |
| `Current Open RAB Exposure` | `Fact_Current_BC` | Sum open RAB exposure |
| `Current High Risk BC Count` | `Fact_Current_BC` | Count high risk BC |
| `Current High Risk RAB Exposure` | `Fact_Current_BC` | Sum high risk RAB exposure |
| `Current Reported Excluded BC Count` | `Fact_Current_BC` | Count reported/excluded BC |
| `Current UNCLASSIFIED PIC Count` | `Fact_Current_BC` | Count BC assigned to UNCLASSIFIED PIC |
| `Current Manual Review BC Count` | `Fact_Current_BC` | Count BC requiring manual review |
| `Current Average Aging Open BC` | `Fact_Current_BC` | Average aging for valid open ended BC |

### 8.2 Control KPI Measures

| Measure Name | Source Table | Purpose |
|---|---|---|
| `Control Total BC Count` | `Control_Current_KPI` | Control baseline for total BC |
| `Control Open BC Count` | `Control_Current_KPI` | Control baseline for open BC |
| `Control Open RAB Exposure` | `Control_Current_KPI` | Control baseline for open RAB exposure |
| `Control High Risk BC Count` | `Control_Current_KPI` | Control baseline for high risk BC |
| `Control High Risk RAB Exposure` | `Control_Current_KPI` | Control baseline for high risk RAB exposure |
| `Control Reported Excluded BC Count` | `Control_Current_KPI` | Control baseline for reported/excluded BC |
| `Control UNCLASSIFIED PIC Count` | `Control_Current_KPI` | Control baseline for UNCLASSIFIED PIC |
| `Control Manual Review BC Count` | `Control_Current_KPI` | Control baseline for manual review BC |
| `Control Average Aging Open BC` | `Control_Current_KPI` | Control baseline for average aging open BC |

### 8.3 Reconciliation Measures

| Measure Name | Purpose |
|---|---|
| `Recon Open BC Diff` | Difference between current open BC and control open BC |
| `Recon Open RAB Diff` | Difference between current open RAB exposure and control open RAB exposure |
| `Recon High Risk BC Diff` | Difference between current high risk BC and control high risk BC |
| `Recon Average Aging Diff` | Difference between current average aging and control average aging |
| `Recon KPI Status` | Overall KPI reconciliation status |

### 8.4 Movement Guardrail Measures

| Measure Name | Purpose |
|---|---|
| `Movement Readiness Flag` | Indicates whether movement has enough latest-per-day snapshot dates |
| `Movement Readiness Status` | Text status for movement readiness |

---

## 9. Core DAX Logic Rule

The Power BI model must use the prepared SQL/snapshot fields.

Do not recreate complex SQL logic in DAX.

### 9.1 Open Backlog Logic

Use:

```text
is_open_unbilled = TRUE
```

Do not use:

```text
billing_status <> "BILLED"
```

Reason:

`billing_status <> "BILLED"` is too simplistic and can incorrectly include reported/excluded records or fail to account for partial invoice and invoice completion logic.

### 9.2 Open Exposure Logic

Use:

```text
open_rab_exposure_amount
```

Do not calculate open exposure from raw `rab_budget_amount` with simplistic status filtering.

Correct approach:

```text
SUM(Fact_Current_BC[open_rab_exposure_amount])
```

### 9.3 Average Aging Logic

Use the following logic:

```text
is_open_unbilled = TRUE
event_status = "ENDED"
unbilled_aging_days > 0
```

Average aging should not include:

1. Closed/fully invoiced BC.
2. Reported/excluded BC.
3. ON GOING event if the KPI is intended to represent aging after event completion.
4. Zero or invalid aging days.

---

## 10. Important Column Notes

### 10.1 Dim_PIC

`reporting.dim_pic` already contains a synthetic row for unclassified PIC.

Expected synthetic row:

| Column | Value |
|---|---|
| `pic_code` | `UNCLASSIFIED` |
| `pic_full_name` | `UNCLASSIFIED - PIC not input in ERP` |
| `division_code` | `UNCLASSIFIED` |
| `pic_status` | `ACTIVE` |
| `is_unclassified_pic` | `TRUE` |

This row is required so that orphan PIC count becomes zero.

`UNCLASSIFIED` is a correction bucket.

It must not be treated as PIC performance penalty.

### 10.2 Dim_Date

Current condition:

```text
Dim_Date rows = 1
distinct_date = 1
```

This is expected because movement latest-per-day snapshot date is currently only one date.

`Dim_Date` is only actively related to:

```text
Fact_Movement_BC[snapshot_date]
```

Do not create active relationship from `Dim_Date` to `Fact_Current_BC`.

### 10.3 Movement

Movement source is structurally safe, but movement trend is not yet analytically meaningful.

Current condition:

```text
latest-per-day distinct_snapshot_dates = 1
```

Movement trend must not be interpreted until:

```text
latest-per-day distinct_snapshot_dates >= 2
```

Allowed at this stage:

1. Build movement table.
2. Build movement relationship to `Dim_Date`.
3. Build movement readiness guardrail.
4. Display movement readiness warning.

Not allowed at this stage:

1. Interpret movement trend as business insight.
2. Claim daily increase/decrease as real movement.
3. Use movement delta for management decision before at least two latest-per-day snapshot dates exist.

---

## 11. Power BI Load Rule

Load only curated reporting views into the main PBIX model.

Approved objects:

```text
reporting.fact_current_bc
reporting.fact_movement_bc
reporting.fact_issue_current
reporting.control_current_kpi
reporting.control_movement_kpi
reporting.dim_pic
reporting.dim_bc
reporting.dim_date
```

Do not load the following objects into the main PBIX model:

```text
raw.*
clean.clean_bc
snapshot.bc_daily_status_snapshot
snapshot.bc_daily_issue_history
```

Reason:

The main PBIX model must consume curated reporting views only.

Raw, clean, and base snapshot tables are allowed for backend validation, SQL development, and troubleshooting, but not for the production-facing Power BI semantic model.

---

## 12. Recommended Measure Container

Create a DAX-only table named:

```text
_Measures
```

All measures should be stored in `_Measures`.

The `_Measures` table should not have relationships.

Recommended display folders:

```text
01 Current KPI
02 Control KPI
03 Reconciliation
04 Movement Guardrail
99 Deprecated / Do Not Use
```

---

## 13. Recommended Canonical DAX

The following DAX is the recommended Phase 12 baseline.

Adjust table or column names only if the Power BI imported table/column names are different.

Do not change business logic without explicit review.

### 13.1 Current KPI Measures

```DAX
Current Total BC Count =
COUNTROWS('Fact_Current_BC')
```

```DAX
Current Open BC Count =
CALCULATE(
    COUNTROWS('Fact_Current_BC'),
    'Fact_Current_BC'[is_open_unbilled] = TRUE()
)
```

```DAX
Current Open RAB Exposure =
SUM('Fact_Current_BC'[open_rab_exposure_amount])
```

```DAX
Current High Risk BC Count =
CALCULATE(
    COUNTROWS('Fact_Current_BC'),
    'Fact_Current_BC'[high_risk_flag] = TRUE()
)
```

```DAX
Current High Risk RAB Exposure =
CALCULATE(
    SUM('Fact_Current_BC'[open_rab_exposure_amount]),
    'Fact_Current_BC'[high_risk_flag] = TRUE()
)
```

```DAX
Current Reported Excluded BC Count =
CALCULATE(
    COUNTROWS('Fact_Current_BC'),
    'Fact_Current_BC'[is_reported_excluded] = TRUE()
)
```

```DAX
Current UNCLASSIFIED PIC Count =
CALCULATE(
    COUNTROWS('Fact_Current_BC'),
    'Fact_Current_BC'[pic_internal_code] = "UNCLASSIFIED"
)
```

```DAX
Current Manual Review BC Count =
CALCULATE(
    COUNTROWS('Fact_Current_BC'),
    'Fact_Current_BC'[manual_review_flag] = TRUE()
)
```

```DAX
Current Average Aging Open BC =
CALCULATE(
    AVERAGE('Fact_Current_BC'[unbilled_aging_days]),
    'Fact_Current_BC'[is_open_unbilled] = TRUE(),
    'Fact_Current_BC'[event_status] = "ENDED",
    'Fact_Current_BC'[unbilled_aging_days] > 0
)
```

### 13.2 Control KPI Measures

```DAX
Control Total BC Count =
MAX('Control_Current_KPI'[total_bc_count])
```

```DAX
Control Open BC Count =
MAX('Control_Current_KPI'[open_bc_count])
```

```DAX
Control Open RAB Exposure =
MAX('Control_Current_KPI'[open_rab_exposure_amount])
```

```DAX
Control High Risk BC Count =
MAX('Control_Current_KPI'[high_risk_bc_count])
```

```DAX
Control High Risk RAB Exposure =
MAX('Control_Current_KPI'[high_risk_rab_exposure_amount])
```

```DAX
Control Reported Excluded BC Count =
MAX('Control_Current_KPI'[reported_excluded_bc_count])
```

```DAX
Control UNCLASSIFIED PIC Count =
MAX('Control_Current_KPI'[unclassified_pic_count])
```

```DAX
Control Manual Review BC Count =
MAX('Control_Current_KPI'[manual_review_bc_count])
```

```DAX
Control Average Aging Open BC =
MAX('Control_Current_KPI'[average_aging_open_bc])
```

### 13.3 Reconciliation Measures

```DAX
Recon Open BC Diff =
[Current Open BC Count] - [Control Open BC Count]
```

```DAX
Recon Open RAB Diff =
[Current Open RAB Exposure] - [Control Open RAB Exposure]
```

```DAX
Recon High Risk BC Diff =
[Current High Risk BC Count] - [Control High Risk BC Count]
```

```DAX
Recon Average Aging Diff =
[Current Average Aging Open BC] - [Control Average Aging Open BC]
```

```DAX
Recon KPI Status =
VAR OpenBCDiff =
    ABS([Recon Open BC Diff])
VAR OpenRABDiff =
    ABS([Recon Open RAB Diff])
VAR HighRiskBCDiff =
    ABS([Recon High Risk BC Diff])
VAR AverageAgingDiff =
    ABS([Recon Average Aging Diff])
RETURN
    IF(
        OpenBCDiff = 0
            && OpenRABDiff = 0
            && HighRiskBCDiff = 0
            && AverageAgingDiff < 0.0001,
        "PASS",
        "NEEDS REVIEW"
    )
```

### 13.4 Movement Guardrail Measures

```DAX
Movement Readiness Flag =
VAR SnapshotDateCount =
    DISTINCTCOUNT('Fact_Movement_BC'[snapshot_date])
RETURN
    IF(
        SnapshotDateCount >= 2,
        1,
        0
    )
```

```DAX
Movement Readiness Status =
VAR SnapshotDateCount =
    DISTINCTCOUNT('Fact_Movement_BC'[snapshot_date])
RETURN
    IF(
        SnapshotDateCount >= 2,
        "READY - movement can be interpreted",
        "NOT READY - movement requires at least 2 latest-per-day snapshot dates"
    )
```

---

## 14. Optional Enhancement for Later Review

The following reconciliation measures may be added later if Phase 12 needs stronger audit coverage.

They are not required for the minimum canonical baseline, but recommended before production-readiness sign-off.

```DAX
Recon Total BC Diff =
[Current Total BC Count] - [Control Total BC Count]
```

```DAX
Recon High Risk RAB Diff =
[Current High Risk RAB Exposure] - [Control High Risk RAB Exposure]
```

```DAX
Recon Reported Excluded BC Diff =
[Current Reported Excluded BC Count] - [Control Reported Excluded BC Count]
```

```DAX
Recon UNCLASSIFIED PIC Diff =
[Current UNCLASSIFIED PIC Count] - [Control UNCLASSIFIED PIC Count]
```

```DAX
Recon Manual Review BC Diff =
[Current Manual Review BC Count] - [Control Manual Review BC Count]
```

If these optional reconciliation measures are added, `Recon KPI Status` should be expanded to check all reconciliation diffs.

---

## 15. Validation Checklist

Before this contract is considered implemented in PBIX, validate the following:

### 15.1 Load Validation

```text
[ ] Only curated reporting views are loaded.
[ ] No raw.* table is loaded.
[ ] No clean.clean_bc table is loaded.
[ ] No snapshot base table is loaded.
[ ] Control_Current_KPI is loaded but disconnected.
[ ] Control_Movement_KPI is loaded but disconnected.
[ ] _Measures table exists and has no relationship.
```

### 15.2 Relationship Validation

```text
[ ] Dim_PIC to Fact_Current_BC relationship exists.
[ ] Dim_PIC to Fact_Movement_BC relationship exists.
[ ] Dim_BC to Fact_Current_BC relationship exists.
[ ] Dim_BC to Fact_Movement_BC relationship exists.
[ ] Dim_BC to Fact_Issue_Current relationship exists.
[ ] Dim_Date to Fact_Movement_BC relationship exists.
[ ] No fact-to-fact relationship exists.
[ ] No control table relationship exists.
[ ] No bidirectional relationship exists.
[ ] No uncontrolled many-to-many relationship exists.
[ ] No active Dim_Date relationship to Fact_Current_BC exists.
```

### 15.3 DAX Validation

```text
[ ] All current KPI measures use Fact_Current_BC.
[ ] All control KPI measures use Control_Current_KPI.
[ ] Reconciliation measures compare current vs control.
[ ] Movement measures are guardrail-only.
[ ] No DAX uses billing_status <> "BILLED" as open backlog logic.
[ ] No duplicate by-PIC/by-customer/by-division measures exist.
[ ] Open exposure uses open_rab_exposure_amount.
[ ] Average aging uses is_open_unbilled, event_status = "ENDED", and unbilled_aging_days > 0.
```

### 15.4 Movement Validation

```text
[ ] Movement readiness status is visible on movement page.
[ ] Movement trend is not interpreted if latest-per-day distinct snapshot dates < 2.
[ ] Movement visuals are treated as structure-only until readiness condition is met.
```

### 15.5 Reconciliation Validation

```text
[ ] Current Open BC Count equals Control Open BC Count.
[ ] Current Open RAB Exposure equals Control Open RAB Exposure.
[ ] Current High Risk BC Count equals Control High Risk BC Count.
[ ] Current Average Aging Open BC equals Control Average Aging Open BC.
[ ] Recon KPI Status returns PASS after model setup.
```

---

## 16. Validation Result

Current document status:

```text
Validation Result: NEEDS REVIEW
Risk Level: MEDIUM
```

Reason:

This contract is ready to be used as the Phase 12 Power BI modeling baseline, but final validation depends on actual PBIX implementation.

This document can become PASS only after:

1. PBIX loads only approved curated reporting views.
2. Relationships match the approved relationship matrix.
3. Control tables remain disconnected.
4. Canonical DAX measures are created.
5. KPI cards reconcile with control tables.
6. Movement guardrail works as expected.
7. User performs final validation.

---

## 17. Final Rule

For Phase 12, Power BI must remain a semantic and visualization layer.

Business logic must primarily come from PostgreSQL curated reporting views and snapshot fields.

Power BI DAX must stay simple, auditable, and aligned with SQL control outputs.
