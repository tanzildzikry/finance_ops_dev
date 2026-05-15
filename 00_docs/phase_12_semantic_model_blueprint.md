# Phase 12 Semantic Model Blueprint — Finance_Ops_Dev

## Status

Phase: 12 — Power BI Semantic Model Build / Relationship Setup  
Status: IN PROGRESS  
Validation Result: NEEDS REVIEW  
Risk Level: LOW  

---

## Objective

Build a lean Power BI semantic model using curated reporting views.

Main goals:
- reduce table/source ambiguity below 3%
- reduce redundant table risk below 2%
- reduce redundant measure risk below 2%
- keep DAX simple
- keep KPI reconciliation auditable
- avoid fact-to-fact relationships
- avoid bidirectional filter ambiguity

---

## Power BI Load List

Load only these curated objects:

| Power BI Name | Source Object | Role |
|---|---|---|
| Fact_Current_BC | reporting.fact_current_bc | Current/latest dashboard fact |
| Fact_Movement_BC | reporting.fact_movement_bc | Movement/trend fact |
| Fact_Issue_Current | reporting.fact_issue_current | Issue drill-through/detail |
| Control_Current_KPI | reporting.control_current_kpi | Disconnected reconciliation |
| Control_Movement_KPI | reporting.control_movement_kpi | Disconnected movement control |
| Dim_PIC | reporting.dim_pic | PIC dimension |
| Dim_BC | reporting.dim_bc | BC dimension / bridge |
| Dim_Date | reporting.dim_date | Date dimension |
| _Measures | DAX-only table | Measure container |

---

## Do Not Load to Main PBIX Model

Do not load:
- raw.raw_bc_source
- raw.raw_pic_list
- clean.clean_bc
- snapshot.bc_daily_status_snapshot
- snapshot.bc_daily_issue_history
- snapshot.snapshot_run_log

Exception:
- Admin/debug page only, if explicitly required.

---

## Source Rules

Current dashboard fact:
- reporting.fact_current_bc
- source: snapshot.vw_latest_bc_daily_status_snapshot

KPI reconciliation:
- reporting.control_current_kpi
- source: snapshot.vw_latest_snapshot_kpi_control

Movement/trend fact:
- reporting.fact_movement_bc
- source: snapshot.vw_daily_status_snapshot_latest_per_day

Movement KPI control:
- reporting.control_movement_kpi
- source: snapshot.vw_daily_kpi_control_latest_per_day

Issue detail:
- reporting.fact_issue_current
- source: snapshot.vw_latest_bc_daily_issue_history

---

## Movement Readiness Rule

Movement source is structurally safe.

Trend interpretation is not allowed until:

```text
latest-per-day distinct_snapshot_dates >= 2
```

If distinct snapshot dates < 2:
- build movement page structurally only
- show readiness warning
- do not interpret trend insight

---

## Naming Rules

Use strict prefixes:

- Fact_
- Dim_
- Control_
- _Measures

Measure prefixes:
- Current ...
- Control ...
- Recon ...
- Movement ...

Do not use ambiguous names such as:
- Open BC
- Total Open BC
- Open Backlog
- Unbilled Amount
- Open RAB

Use canonical names only.
