# Phase 12 — Dashboard Blueprint v1

**Project:** Finance_Ops_Dev  
**Phase:** Phase 12 — Power BI Dashboard Baseline  
**Document Type:** Dashboard Blueprint / Visual Execution Contract  
**Recommended File Name:** `phase_12_dashboard_blueprint_v1.md`  
**Status:** ACTIVE BASELINE  
**Validation Status:** NEEDS REVIEW until visual pages, slicer behavior, drill-through behavior, and user final validation are completed  
**Risk Level:** MEDIUM before visual validation, LOW after reconciliation and page behavior checks pass  

---

## 1. Purpose

This document defines the Phase 12 dashboard blueprint for the Finance_Ops_Dev Power BI report.

The blueprint is intentionally narrower and more execution-ready than the broader strategic dashboard design.

It is designed to match the current validated semantic model:

- curated `reporting.*` views only,
- approved relationships only,
- disconnected control tables,
- canonical DAX measures,
- reconciliation-first validation,
- movement guardrail before trend interpretation,
- issue and blocker analysis through current issue fact,
- PIC analysis as pressure mapping, not punitive scoring.

This document should be used as the baseline for building dashboard pages in Power BI.

---

## 2. Current Model Readiness Baseline

Current semantic model status:

```text
Relationship setup: PASS
Control tables disconnected: PASS
Current KPI measures: PASS
Control KPI measures: PASS
Reconciliation measures: PASS
Movement guardrail measures: PASS
Recon KPI Status: PASS
SQL sort-order columns: PASS
```

The following sort-order columns have been added in the SQL reporting layer:

### `reporting.fact_current_bc`

```text
aging_bucket_order
risk_level_order
bc_closing_status_order
```

### `reporting.fact_movement_bc`

```text
aging_bucket_order
risk_level_order
bc_closing_status_order
```

### `reporting.fact_issue_current`

```text
invoice_completion_bucket_order
bc_closing_status_order
responsibility_type_order
issue_confidence_level_order
```

Validation result from SQL patch:

```text
fact_current_bc row_count = 8266
fact_movement_bc row_count = 8266
fact_issue_current row_count = 8266

All sort-order count checks = 8266
```

---

## 3. Dashboard Design Principle

The dashboard must answer:

```text
Can we trust the numbers?
What is exposed?
Where is the risk?
Who owns the pressure?
Why is it not closing?
Is movement ready to be interpreted?
```

Recommended reading flow:

```text
Trust → Exposure → Action → Ownership → Issue → Movement Readiness
```

This is stronger than immediately building many pages because it keeps Phase 12 focused, auditable, and aligned with the model that is already available.

---

## 4. Final Phase 12 Dashboard Page Order

Use the following page order:

```text
00_Reconciliation_Check
01_Executive_Control_Tower
02_AR_Action_Board
03_PIC_Pressure_Map
04_Issue_Drilldown
05_Movement_Readiness
```

Pages postponed for later phases:

```text
Full Daily Movement Trend Page
Full PIC Operation Scoring
BC Case File Drillthrough
Data Quality Deep Dive
Customer / Division Deep Dive
```

These postponed pages require additional validation, more snapshot dates, or stronger drill-through/user behavior testing.

---

# Page 00 — Reconciliation Check

## Purpose

Trust layer.

This page answers:

```text
Can we trust the Power BI numbers against SQL control?
```

This page must be built and validated before executive or operational pages are used for decision-making.

---

## Recommended Visuals

### 1. KPI Status Card

Use:

```text
Recon KPI Status
```

Expected result:

```text
PASS
```

### 2. Movement Guardrail Card

Use:

```text
Movement Readiness Status
```

Expected current result:

```text
NOT READY - movement requires at least 2 latest-per-day snapshot dates
```

### 3. Reconciliation Difference Table

Use:

```text
Recon Open BC Diff
Recon Open RAB Diff
Recon High Risk BC Diff
Recon High Risk RAB Diff
Recon Reported Excluded BC Diff
Recon UNCLASSIFIED PIC Diff
Recon Manual Review BC Diff
Recon Average Aging Diff
```

If manual review reconciliation is not yet available, add it after manual review measures are created.

### 4. Current vs Control Table

Use:

```text
Current Total BC Count
Control Total BC Count

Current Open BC Count
Control Open BC Count

Current Open RAB Exposure
Control Open RAB Exposure

Current High Risk BC Count
Control High Risk BC Count

Current High Risk RAB Exposure
Control High Risk RAB Exposure

Current Reported Excluded BC Count
Control Reported Excluded BC Count

Current UNCLASSIFIED PIC Count
Control UNCLASSIFIED PIC Count

Current Manual Review BC Count
Control Manual Review BC Count

Current Average Aging Open BC
Control Average Aging Open BC
```

---

## Controls

This page must not use slicers that make control tables appear sliced.

Control tables must remain disconnected.

Expected behavior:

```text
Current measures respond to report filters.
Control measures remain baseline reconciliation values.
Recon page should usually be reviewed without operational slicers.
```

---

# Page 01 — Executive Control Tower

## Purpose

Executive summary and action priority.

This page answers:

```text
How much exposure is open, where is the risk, who owns the pressure, and which BCs need attention first?
```

---

## Recommended Slicers

Keep slicers compact.

Use maximum 5 visible slicers:

```text
PIC
Customer
Event Category / Division
Aging Bucket
Risk Level
```

Avoid too many slicers on this page.

Do not put control table fields as slicers.

---

## KPI Cards

Use:

```text
Current Open BC Count
Current Open RAB Exposure
Current High Risk BC Count
Current High Risk RAB Exposure
Current High Risk RAB Ratio
Current Average Aging Open BC
Current UNCLASSIFIED PIC Count
Recon KPI Status
```

If `Current High Risk RAB Ratio` is not yet created, add:

```DAX
Current High Risk RAB Ratio =
DIVIDE(
    [Current High Risk RAB Exposure],
    [Current Open RAB Exposure]
)
```

Display folder:

```text
01 Current KPI
```

Format:

```text
Percentage
```

---

## Main Visual — Risk Exposure Matrix

Use matrix:

```text
Rows    = fact_current_bc[aging_bucket]
Columns = fact_current_bc[risk_level]
Values  = Current Open RAB Exposure
```

Sort setup:

```text
fact_current_bc[aging_bucket] sort by fact_current_bc[aging_bucket_order]
fact_current_bc[risk_level] sort by fact_current_bc[risk_level_order]
```

Purpose:

```text
Shows how open exposure is distributed by aging and risk.
```

---

## Top Owner Visual

Use bar chart:

```text
Axis   = dim_pic[pic_full_name]
Values = Current High Risk RAB Exposure
Filter = Top 10 by Current High Risk RAB Exposure
```

Add note:

```text
UNCLASSIFIED is a correction bucket, not PIC performance penalty.
```

---

## Top Customer Visual

Use bar chart:

```text
Axis   = fact_current_bc[customer_name]
Values = Current Open RAB Exposure
Filter = Top 10 by Current Open RAB Exposure
```

Temporary note:

```text
Customer is still fact-based in Phase 12.
A dedicated Dim_Customer can be added in a later enhancement.
```

---

## Executive Action Table

Use table:

```text
fact_current_bc[bc_number]
fact_current_bc[customer_name]
fact_current_bc[pic_internal_code]
fact_current_bc[event_category]
fact_current_bc[event_status]
fact_current_bc[billing_status]
fact_current_bc[bc_closing_status]
fact_current_bc[unbilled_aging_days]
fact_current_bc[aging_bucket]
fact_current_bc[open_rab_exposure_amount]
fact_current_bc[risk_level]
fact_current_bc[detected_issue_category]
fact_current_bc[detected_blocker]
fact_current_bc[responsibility_type]
```

Visual filter:

```text
fact_current_bc[is_open_unbilled] = TRUE
```

Sort recommendation:

```text
Current High Risk RAB Exposure descending
or
fact_current_bc[open_rab_exposure_amount] descending
```

---

## Guardrails

Do not show movement trend in this page.

Do not show raw cashflow, actual cash-in, DSO, or collection performance.

Do not use `billing_status <> "BILLED"` as open backlog logic.

Use:

```text
is_open_unbilled
open_rab_exposure_amount
```

---

# Page 02 — AR Action Board

## Purpose

Operational follow-up page.

This page answers:

```text
Which BCs must be chased today and what is blocking them?
```

---

## Recommended Slicers

```text
PIC
Customer
Aging Bucket
Risk Level
Detected Issue Category
Detected Blocker
Responsibility Type
```

Use operational slicers here; this page can have more slicers than the executive page.

---

## KPI Cards

Use:

```text
Current Open BC Count
Current Open RAB Exposure
Current High Risk BC Count
Current High Risk RAB Exposure
Current Manual Review BC Count
Current Avg Open RAB per Open BC
```

If `Current Avg Open RAB per Open BC` is not yet created, add:

```DAX
Current Avg Open RAB per Open BC =
DIVIDE(
    [Current Open RAB Exposure],
    [Current Open BC Count]
)
```

Display folder:

```text
01 Current KPI
```

Format:

```text
Decimal number or currency-style amount
```

If manual review measures are not yet created, add:

```DAX
Current Manual Review BC Count =
CALCULATE(
    COUNTROWS('fact_current_bc'),
    'fact_current_bc'[needs_manual_review_flag] = TRUE()
)
```

Display folder:

```text
01 Current KPI
```

---

## Main Table — Daily Follow-Up List

Use table:

```text
fact_current_bc[bc_number]
fact_current_bc[customer_name]
fact_current_bc[pic_internal_code]
fact_current_bc[event_category]
fact_current_bc[unbilled_aging_days]
fact_current_bc[aging_bucket]
fact_current_bc[open_rab_exposure_amount]
fact_current_bc[risk_level]
fact_current_bc[detected_issue_category]
fact_current_bc[detected_blocker]
fact_current_bc[responsibility_type]
fact_current_bc[needs_manual_review_flag]
fact_current_bc[issue_source_text]
```

Visual filter:

```text
fact_current_bc[is_open_unbilled] = TRUE
```

Default sort:

```text
fact_current_bc[open_rab_exposure_amount] descending
then fact_current_bc[unbilled_aging_days] descending
```

---

## Supporting Visuals

### Blocker Count

```text
Axis   = fact_current_bc[detected_blocker]
Values = Current Open BC Count
```

### Responsibility Type

```text
Axis   = fact_current_bc[responsibility_type]
Values = Current Open BC Count
```

### Aging Exposure

```text
Axis   = fact_current_bc[aging_bucket]
Values = Current Open RAB Exposure
Sort   = aging_bucket_order
```

---

## Guardrails

This page is for work prioritization, not executive storytelling.

Avoid too many narrative cards.

Use clear action-oriented table formatting.

---

# Page 03 — PIC Pressure Map

## Purpose

Ownership and workload pressure page.

This page intentionally uses the term:

```text
PIC Pressure Map
```

instead of:

```text
PIC Operation Scoring
```

for Phase 12 baseline.

Reason:

```text
The current model can show pressure, exposure, risk, aging, and manual review.
It should not yet claim final PIC performance scoring until controllability logic is fully validated.
```

---

## Recommended Slicers

```text
PIC
Event Category / Division
Aging Bucket
Risk Level
Responsibility Type
Include / Exclude UNCLASSIFIED
```

If no formal UNCLASSIFIED toggle exists, use `dim_pic[is_unclassified_pic]` as a slicer.

---

## KPI Cards

Use:

```text
Current Open BC Count
Current Open RAB Exposure
Current High Risk BC Count
Current High Risk RAB Exposure
Current Average Aging Open BC
Current Manual Review BC Count
```

---

## Main Visual — PIC Pressure Scatter

Use scatter chart:

```text
X-axis  = Current Average Aging Open BC
Y-axis  = Current Open RAB Exposure
Size    = Current Open BC Count
Details = dim_pic[pic_full_name]
Legend  = dim_pic[division_code]
```

Purpose:

```text
Shows which PICs carry high exposure and high aging pressure.
```

---

## Ranking Table

Use table:

```text
dim_pic[pic_full_name]
dim_pic[division_code]
dim_pic[is_unclassified_pic]
Current Open BC Count
Current Open RAB Exposure
Current High Risk BC Count
Current High Risk RAB Exposure
Current Average Aging Open BC
Current Manual Review BC Count
```

---

## Required Control Note

Add text box:

```text
UNCLASSIFIED = correction bucket, not PIC performance penalty.
```

---

## Guardrails

Do not title this page as final performance scoring yet.

Do not imply PIC penalty from UNCLASSIFIED.

Do not ignore responsibility type; customer/internal/shared blockers should not be treated the same as PIC-controlled blockers.

---

# Page 04 — Issue Drilldown

## Purpose

Issue and blocker explanation page.

This page answers:

```text
Why is the BC not closing and who controls the blocker?
```

---

## Recommended Slicers

```text
Detected Issue Category
Detected Blocker
Responsibility Type
Issue Confidence Level
Manual Review Flag
PIC
BC Number
```

---

## KPI Cards

Use:

```text
Current Manual Review BC Count
Current Open BC Count
Current High Risk BC Count
```

If issue-specific manual review count is needed later, create a dedicated measure using `fact_issue_current`.

Do not create it yet unless required.

---

## Main Visuals

### Issue Category

```text
Axis   = fact_issue_current[detected_issue_category]
Values = Count of fact_issue_current[bc_number]
```

### Detected Blocker

```text
Axis   = fact_issue_current[detected_blocker]
Values = Count of fact_issue_current[bc_number]
```

### Responsibility × Confidence Matrix

```text
Rows    = fact_issue_current[responsibility_type]
Columns = fact_issue_current[issue_confidence_level]
Values  = Count of fact_issue_current[bc_number]
```

Sort setup:

```text
fact_issue_current[responsibility_type] sort by fact_issue_current[responsibility_type_order]
fact_issue_current[issue_confidence_level] sort by fact_issue_current[issue_confidence_level_order]
```

---

## Detail Table

Use table:

```text
fact_issue_current[bc_number]
fact_issue_current[billing_status]
fact_issue_current[event_status]
fact_issue_current[invoice_completion_bucket]
fact_issue_current[bc_closing_status]
fact_issue_current[detected_issue_category]
fact_issue_current[detected_blocker]
fact_issue_current[responsibility_type]
fact_issue_current[issue_confidence_level]
fact_issue_current[needs_manual_review_flag]
fact_issue_current[raw_remarks]
fact_issue_current[raw_missing_document_notes]
fact_issue_current[raw_po_status]
fact_issue_current[raw_umk_status]
fact_issue_current[issue_source_text]
```

---

## Guardrails

Issue classification must not rely on single keyword interpretation.

Positive phrases must be interpreted before negative phrases.

Example:

```text
"PO sudah ada, proses upload iVendor"
```

must not be classified as:

```text
PO_NOT_ISSUED
```

It should be treated as a positive PO availability signal with iVendor process context.

---

# Page 05 — Movement Readiness

## Purpose

Movement control page.

This page answers:

```text
Is movement ready to be interpreted?
```

For Phase 12 current condition, this is not a trend insight page.

---

## KPI Cards

Use:

```text
Movement Snapshot Date Count
Movement Readiness Flag
Movement Readiness Status
```

Expected current status:

```text
NOT READY - movement requires at least 2 latest-per-day snapshot dates
```

---

## Main Table

Use table:

```text
fact_movement_bc[snapshot_date]
fact_movement_bc[bc_number]
fact_movement_bc[pic_internal_code]
fact_movement_bc[customer_name]
fact_movement_bc[event_category]
fact_movement_bc[open_rab_exposure_amount]
fact_movement_bc[aging_bucket]
fact_movement_bc[risk_level]
```

---

## Required Warning Text

Add text box:

```text
Movement trend must not be interpreted until latest-per-day snapshot dates >= 2.
```

---

## Do Not Add Yet

Do not add these yet:

```text
Open BC Movement
Open RAB Movement
High Risk Movement
Movement trend line
Daily increase/decrease narrative
```

Reason:

```text
Movement currently has structure readiness, but not enough latest-per-day snapshot dates for business interpretation.
```

---

# 5. Global Slicer Strategy

## Recommended Global Slicers

Use only when appropriate per page:

```text
PIC
Customer
Event Category / Division
Aging Bucket
Risk Level
```

## Slicer Rules

- Executive page must be cleanest.
- Operational pages may have more slicers.
- Do not put control table fields as slicers.
- Do not use movement date slicer for executive interpretation until movement readiness is valid.
- Fact-based customer slicers are acceptable for Phase 12 page-level use, but should not be treated as a fully global dimension slicer.

---

# 6. Visual Style Guide

## Layout

Use 16:9 canvas.

Recommended page structure:

```text
Top: title + status badges
Row 1: KPI cards
Middle: dominant visual
Right: ranking / concentration visual
Bottom: exception or detail table
```

## Color Direction

Use simple corporate colors:

```text
Base: white / light grey
Text: dark navy / charcoal
Neutral: blue
Warning: amber
High risk: red
Pass/reconciled: green
```

Avoid excessive colors.

## Narrative Rule

Every page should answer one clear question.

Do not write long explanations inside the dashboard.

Use short notes only where there is risk of misinterpretation:

```text
UNCLASSIFIED correction bucket
Movement not ready
Control tables disconnected
Recon status
```

---

# 7. Dashboard Guardrails

The dashboard must follow these rules:

```text
Do not mix REPORTED with active open backlog.
Do not use billing_status <> BILLED as open logic.
Use is_open_unbilled for open backlog.
Use open_rab_exposure_amount for open exposure.
Do not show actual cashflow, actual cash-in, DSO, or collection performance.
Do not interpret daily movement before at least two valid latest-per-day snapshot dates.
Keep DAX simple.
Use control tables for reconciliation only.
Keep control tables disconnected.
Do not build fact-to-fact relationships.
Do not use bidirectional filters.
```

---

# 8. Required Power BI Model Adjustments

Before or during visual build, complete these model adjustments:

## 8.1 Manual Review Measures

Add:

```DAX
Current Manual Review BC Count =
CALCULATE(
    COUNTROWS('fact_current_bc'),
    'fact_current_bc'[needs_manual_review_flag] = TRUE()
)
```

```DAX
Control Manual Review BC Count =
MAX('control_current_kpi'[manual_review_bc_count])
```

```DAX
Recon Manual Review BC Diff =
[Current Manual Review BC Count] - [Control Manual Review BC Count]
```

Update `Recon KPI Status` to include `Recon Manual Review BC Diff`.

---

## 8.2 Optional Current KPI Enhancements

Add:

```DAX
Current High Risk RAB Ratio =
DIVIDE(
    [Current High Risk RAB Exposure],
    [Current Open RAB Exposure]
)
```

```DAX
Current High Risk BC Ratio =
DIVIDE(
    [Current High Risk BC Count],
    [Current Open BC Count]
)
```

```DAX
Current Avg Open RAB per Open BC =
DIVIDE(
    [Current Open RAB Exposure],
    [Current Open BC Count]
)
```

---

## 8.3 Sort-by-Column Setup

After Power BI refresh, set:

```text
fact_current_bc[aging_bucket] → fact_current_bc[aging_bucket_order]
fact_current_bc[risk_level] → fact_current_bc[risk_level_order]
fact_current_bc[bc_closing_status] → fact_current_bc[bc_closing_status_order]

fact_movement_bc[aging_bucket] → fact_movement_bc[aging_bucket_order]
fact_movement_bc[risk_level] → fact_movement_bc[risk_level_order]
fact_movement_bc[bc_closing_status] → fact_movement_bc[bc_closing_status_order]

fact_issue_current[invoice_completion_bucket] → fact_issue_current[invoice_completion_bucket_order]
fact_issue_current[bc_closing_status] → fact_issue_current[bc_closing_status_order]
fact_issue_current[responsibility_type] → fact_issue_current[responsibility_type_order]
fact_issue_current[issue_confidence_level] → fact_issue_current[issue_confidence_level_order]
```

Hide all `_order` columns after sort setup.

---

# 9. Known Limitations

Current limitations:

```text
Movement is not ready for trend interpretation because latest-per-day snapshot dates are still insufficient.
Customer is currently fact-based, not a dedicated dimension.
Event Category / Division is currently fact-based, not a dedicated dimension.
PIC page is pressure mapping, not final scoring.
BC Case File Drillthrough is postponed.
Full Data Quality deep dive is postponed.
```

Recommended later enhancements:

```text
Dim_Customer
Dim_Event_Category
BC Case File drillthrough page
Movement trend page after snapshot dates >= 2
Controllability scoring for PIC
Action priority / urgent BC measure refinement
```

---

# 10. Validation Checklist

Before considering this dashboard baseline reviewed, validate:

```text
[ ] Recon KPI Status = PASS.
[ ] Movement Readiness Status is visible.
[ ] Movement is not interpreted as trend.
[ ] Executive page uses Current measures only, not Control measures.
[ ] Control measures are only shown in Reconciliation page.
[ ] Sort order works for aging, risk, closing status, responsibility, and confidence.
[ ] UNCLASSIFIED note is visible on PIC page.
[ ] No cashflow/DSO/collection measure is shown.
[ ] REPORTED is excluded from active open backlog.
[ ] No visual uses billing_status <> BILLED as open logic.
[ ] No fact-to-fact relationship is created.
[ ] Control tables remain disconnected.
[ ] User validates page narrative.
```

---

# 11. Validation Result

Current blueprint status:

```text
Validation Result: NEEDS REVIEW
Risk Level: MEDIUM
```

Reason:

This blueprint is aligned with the current Phase 12 semantic model and SQL reporting layer, but it still requires:

```text
Power BI visual implementation
Sort-by-column setup validation
Manual review reconciliation update
Page-level slicer behavior validation
Drill-through behavior validation if added later
User final validation
```

This blueprint can move to:

```text
PASS STRUCTURE ONLY
```

after all six pages are built and basic visual behavior is validated.

It can move to:

```text
PASS
```

only after user final validation.
