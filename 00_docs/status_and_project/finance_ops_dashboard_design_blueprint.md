# Finance Ops Dashboard Design Blueprint

**Project:** Finance Ops Dev  
**Dashboard Scope:** Unbilled Monitoring, Executive Overview, AR Controller, PIC Operation Scoring, Daily Movement, Data Quality Control  
**Design Concept:** Clean corporate, minimalis, impactful, narrative-driven, reader-efficient  
**Status:** Design blueprint for Power BI dashboard structure  
**Production Note:** Dashboard design is not production-ready until Power BI model validation, reconciliation, movement readiness, and user final validation are completed.

---

## 1. Dashboard Design Principles

- Executive-to-operational reading flow.
- Minimal visual noise.
- KPI first, explanation second, action third.
- Every page must answer one clear business question.
- Use narrative storytelling: **what happened → why it matters → who owns it → what action is needed**.
- Avoid long text explanations inside dashboard.
- Use clean corporate layout: white/neutral background, strong KPI cards, limited accent colors.
- Do not label anything as actual cashflow, actual cash-in, DSO, or collection performance until cash-in data exists.
- Do not interpret movement trend until there are at least two valid latest-per-day snapshot dates.
- REPORTED must stay excluded from active open backlog.
- UNCLASSIFIED PIC is a correction bucket, not PIC performance penalty.

---

## 2. Recommended Page Order

1. Executive Control Tower
2. Unbilled Exposure Summary
3. AR Controller Daily Action Board
4. PIC Operation Scoring / PIC Control
5. Daily Movement Monitor
6. Issue & Blocker Intelligence
7. Data Quality & Reconciliation Control
8. BC Drillthrough / Case File

---

# Page 1 — Executive Control Tower

## Reader Flow

**What is exposed → where is risk → who needs attention → what action today**

## Suggested Slicers

- Snapshot Date / Latest Snapshot
- Event Category / Division
- PIC
- Customer
- Aging Bucket
- Risk Level

## Visual Blueprint

- Header:
  - Title: **Finance Ops Control Tower**
  - Subtitle: **Latest Snapshot | Unbilled Exposure | Risk | Action Priority**
  - Right badge: **Recon KPI Status**
- KPI cards:
  - **Open BC**
  - **Open RAB Exposure**
  - **High Risk BC**
  - **High Risk RAB**
  - **Avg Aging Open BC**
  - **UNCLASSIFIED PIC**
- Main visual:
  - Risk matrix: **Aging Bucket × RAB Exposure**
- Right panel:
  - **Top 5 PIC by High Risk Exposure**
  - **Top 5 Customer by Open Exposure**
- Bottom action strip:
  - **Top 10 Urgent BC**
  - Suggested columns:
    - BC Number
    - PIC
    - Customer
    - Aging
    - RAB
    - Blocker
- Narrative card:
  - “Exposure terkonsentrasi pada [PIC/Customer], risiko utama berasal dari aging tinggi dan high-value BC.”

## Design Notes

- Keep slicer top bar compact.
- Default view should use latest snapshot only.
- Avoid too many slicers on executive page.
- Do not show raw operational detail unless it is exception-based.

---

# Page 2 — Unbilled Exposure Summary

## Reader Flow

**Size → composition → concentration → exception**

## Suggested Slicers

- Snapshot Date
- Event Category / Division
- Customer
- PIC
- Aging Bucket
- Billing Status
- BC Closing Status
- Invoice Completion Bucket

## Visual Blueprint

- KPI cards:
  - **Open RAB Exposure**
  - **Open BC Count**
  - **High Risk Ratio**
  - **Reported Excluded BC**
- Visual left:
  - Bar chart: **Open RAB by Aging Bucket**
- Visual center:
  - Bar chart: **Open RAB by Event Category / Division**
- Visual right:
  - Pareto chart: **Customer Exposure Contribution**
- Bottom table:
  - **High Value Open BC**
  - Suggested columns:
    - BC Number
    - Customer
    - PIC
    - Event Category
    - Aging Bucket
    - Risk Level
    - Open RAB Exposure
- Narrative card:
  - “Unbilled bukan hanya volume; prioritas utama adalah kombinasi aging tinggi, exposure besar, dan blocker yang jelas.”

## Design Notes

- Use this page for exposure composition.
- Billing Status and BC Closing Status are used for validation context, not as replacement for open backlog logic.
- Main amount basis should remain open exposure, not total invoice or cash-in.

---

# Page 3 — AR Controller Daily Action Board

## Reader Flow

**What must be chased today → why stuck → who owns it**

## Suggested Slicers

- Snapshot Date / Latest Snapshot
- PIC
- Customer
- Aging Bucket
- Risk Level
- Detected Issue Category
- Detected Blocker
- Responsibility Type
- Issue Confidence Level
- Manual Review Flag

## Visual Blueprint

- KPI cards:
  - **Urgent BC**
  - **Manual Review BC**
  - **Missing / Unknown Issue**
  - **Open RAB Actionable**
- Main table:
  - **Daily Follow-Up List**
  - Suggested columns:
    - BC Number
    - PIC
    - Customer
    - Aging Days
    - Open RAB Exposure
    - Detected Issue Category
    - Detected Blocker
    - Responsibility Type
    - Confidence Level
- Side visual:
  - Bar or donut: **Responsibility Type**
- Bottom visual:
  - Bar chart: **Detected Blocker Count**
- Narrative action card:
  - “Halaman ini bukan untuk membaca semua data; ini adalah daftar kerja harian.”

## Design Notes

- This page is operational and action-oriented.
- Default sort:
  - Risk Level
  - Open RAB Exposure
  - Aging Days
- Slicers should support daily follow-up, escalation, and ownership review.

---

# Page 4 — PIC Operation Scoring / PIC Control

## Reader Flow

**Who carries pressure → is it fair → what should be escalated**

## Suggested Slicers

- Snapshot Date
- PIC
- Event Category / Division
- Aging Bucket
- Risk Level
- Responsibility Type
- Manual Review Flag
- Include / Exclude UNCLASSIFIED PIC

## Visual Blueprint

- KPI cards:
  - **PIC Open RAB Exposure**
  - **PIC High Risk BC**
  - **PIC Avg Aging**
  - **PIC Manual Review**
- Main visual:
  - Scatter chart: **Open RAB Exposure vs Avg Aging**
  - Size: Open BC Count
  - Legend: Risk Level or PIC Status
- Ranking visuals:
  - **Top PIC by High Risk Exposure**
  - **Top PIC by Manual Review Count**
- Detail table:
  - PIC
  - Open BC
  - Open RAB Exposure
  - High Risk BC
  - Average Aging
  - Manual Review Count
  - UNCLASSIFIED Flag
- Control note card:
  - **UNCLASSIFIED = correction bucket, not PIC penalty**
- Narrative card:
  - “PIC scoring harus membaca pressure dan controllability, bukan sekadar menghukum volume backlog.”

## Design Notes

- Do not use UNCLASSIFIED as PIC penalty.
- Add a clear toggle for Include / Exclude UNCLASSIFIED PIC.
- This page should separate workload pressure from controllable performance.

---

# Page 5 — Daily Movement Monitor

## Reader Flow

**Is movement ready → what changed → is trend valid**

## Suggested Slicers

- Snapshot Date Range
- PIC
- Event Category / Division
- Customer
- Aging Bucket
- Risk Level
- Movement Type
- Snapshot Run Status

## Visual Blueprint

- Top warning banner:
  - **Movement Readiness Status**
  - If valid snapshot date count is below 2:
    - “Structure only — trend belum boleh diinterpretasi.”
- KPI cards:
  - **Movement Snapshot Date Count**
  - **Open BC Movement**
  - **Open RAB Movement**
  - **High Risk Movement**
- Main visual:
  - Line chart: **Open RAB Exposure by Snapshot Date**
- Secondary visual:
  - Line or column chart: **Open BC Count by Snapshot Date**
- Bottom table:
  - Snapshot Date
  - Open BC
  - Open RAB Exposure
  - High Risk BC
  - Average Aging
- Narrative card:
  - “Movement hanya valid setelah minimal dua latest-per-day snapshot; sebelum itu halaman ini menjadi readiness monitor.”

## Design Notes

- Main slicer must be date range.
- Do not interpret movement trend before movement readiness is valid.
- Movement page should show readiness and control first, trend second.

---

# Page 6 — Issue & Blocker Intelligence

## Reader Flow

**Why not closed → what blocks closing → who controls the blocker**

## Suggested Slicers

- Snapshot Date
- Detected Issue Category
- Detected Blocker
- Responsibility Type
- Issue Confidence Level
- Manual Review Flag
- PIC
- Customer
- Aging Bucket
- Risk Level

## Visual Blueprint

- KPI cards:
  - **Top Issue Category**
  - **Manual Review BC**
  - **Unknown Issue**
  - **Customer-Controlled Blocker**
- Main visual:
  - Bar chart: **Detected Issue Category**
- Second visual:
  - Bar chart: **Detected Blocker**
- Right visual:
  - Matrix: **Responsibility Type × Risk Level**
- Bottom drill table:
  - BC Number
  - Raw Remarks
  - Missing Document Notes
  - PO Status
  - UMK Status
  - Detected Issue Category
  - Confidence Level
- Narrative card:
  - “Remarks diubah menjadi control signal; fokusnya bukan teks mentah, tetapi blocker yang bisa ditindak.”

## Design Notes

- Confidence slicer is important to separate strong classification from manual review.
- Issue classification must not rely on single keyword only.
- This page should support blocker analysis and escalation routing.

---

# Page 7 — Data Quality & Reconciliation Control

## Reader Flow

**Can we trust the dashboard → what failed → what must be fixed**

## Suggested Slicers

- Snapshot Date
- Recon Status
- Data Quality Flag
- Manual Review Flag
- PIC
- Event Category / Division
- Billing Status
- BC Closing Status
- Source File Name

## Visual Blueprint

- KPI cards:
  - **Recon KPI Status**
  - **Recon Open BC Diff**
  - **Recon Open RAB Diff**
  - **Manual Review BC**
  - **UNCLASSIFIED PIC**
- Main visual:
  - Matrix: **Current Measure vs Control Measure vs Difference**
- Right visual:
  - Bar chart: **Data Quality Flag**
- Bottom table:
  - **Records Needing Review**
  - Suggested columns:
    - BC Number
    - PIC
    - Customer
    - Issue
    - Data Quality Flag
    - Manual Review Flag
    - Recon Impact
- Narrative card:
  - “Dashboard boleh dipakai untuk keputusan hanya jika angka utama reconcile dengan control baseline.”

## Design Notes

- This page is the trust layer.
- Source File Name is useful for upload/source tracing.
- Keep visuals limited and control-focused.
- Reconciliation failure should be visually obvious.

---

# Page 8 — BC Drillthrough / Case File

## Reader Flow

**One BC → full status → blocker → next action**

## Suggested Slicers

- BC Number
- Snapshot Date
- PIC
- Customer
- Detected Issue Category
- Risk Level

## Visual Blueprint

- Header:
  - BC Number
  - Customer
  - PIC
  - Snapshot Date
- Mini cards:
  - **RAB**
  - **Total Invoiced**
  - **Invoice Completion Ratio**
  - **Aging Days**
  - **Risk Level**
- Status strip:
  - Event Status
  - Billing Status
  - BC Closing Status
  - Reported / Excluded Flag
- Issue panel:
  - Detected Issue Category
  - Detected Blocker
  - Responsibility Type
  - Confidence Level
- Text box:
  - Issue Source Text
  - Raw Remarks
  - Missing Documents
- Bottom placeholder:
  - **Recommended Action**
  - Manual until action recommendation logic is approved
- Narrative card:
  - “Satu BC harus bisa dijelaskan dalam 30 detik: status, gap, blocker, owner, next action.”

## Design Notes

- This should be a drillthrough page, not a primary exploration page.
- Main slicers should be BC Number and Snapshot Date.
- Other fields should mostly arrive as drillthrough filters from previous pages.

---

# 3. Global Slicer Strategy

## Recommended Global Slicers

- Snapshot Date
- PIC
- Event Category / Division
- Customer
- Aging Bucket
- Risk Level

## Functional Slicers by Page Type

- Executive:
  - Minimal slicers only
  - Focus on latest snapshot, PIC, customer, risk
- AR Controller:
  - Issue, blocker, responsibility, manual review
- PIC Scoring:
  - PIC, risk, responsibility, UNCLASSIFIED toggle
- Daily Movement:
  - Date range, movement type, snapshot run status
- Data Quality Control:
  - Recon status, DQ flag, source file
- Drillthrough:
  - BC number and snapshot date

## Slicer Layout Rules

- Maximum 5–6 visible slicers per page.
- Additional slicers should go to Filter Pane or collapsible slicer panel.
- Executive page must be the cleanest.
- Operational page may have more slicers because it supports daily work.
- Drillthrough page must stay focused on one BC.

---

# 4. Visual Style Guide

## Layout

- Use 16:9 canvas.
- Use top navigation tabs or vertical left navigation.
- Use KPI card row at top for pages with summary purpose.
- Use a single dominant visual per page.
- Use detail table only when it supports action or audit.

## Color Direction

- Base:
  - White
  - Light grey
  - Dark navy / charcoal text
- Accent:
  - Blue for neutral information
  - Amber for warning
  - Red for high risk
  - Green only for pass/closed/reconciled status
- Avoid excessive colors.

## Typography

- Page title: short and business-focused.
- Visual title: action-oriented, not technical.
- KPI labels: concise.
- Avoid long paragraph explanations.

## Narrative Method

Each page should communicate:

1. **Situation**
2. **Risk**
3. **Owner**
4. **Action**

---

# 5. Dashboard Guardrails

- Do not mix REPORTED with active open backlog.
- Do not use `billing_status <> BILLED` as open logic.
- Use open backlog flags and open exposure fields from reporting/snapshot layer where available.
- Do not show actual cashflow unless cash-in data exists.
- Do not interpret daily movement before at least two valid snapshot dates exist.
- Keep DAX simple; avoid recreating complex SQL logic in Power BI.
- Use control tables for reconciliation.
- Keep Data Quality page visible in the report, not hidden from users.
- Production-ready status requires schema validation, relationship validation, KPI reconciliation, refresh validation, report mapping validation, and user final validation.

---

# 6. Validation Status

**Validation Result:** NEEDS REVIEW  
**Risk Level:** MEDIUM  

## Reason

This dashboard blueprint is structurally aligned with the current Finance Ops Dev direction, but final approval depends on:

- Power BI table load validation.
- Relationship validation.
- Measure-to-control reconciliation.
- Movement readiness check.
- User review of business narrative.
- Final visual implementation review.

