# Phase 12 Relationship Matrix — Finance_Ops_Dev

## Status

Phase: 12  
Status: IN PROGRESS  
Validation Result: NEEDS REVIEW  
Risk Level: LOW  

---

## Approved Active Relationships

| From Table | From Column | To Table | To Column | Cardinality | Direction | Status |
|---|---|---|---|---|---|---|
| Dim_PIC | pic_code | Fact_Current_BC | pic_internal_code | 1:* | Single | Active |
| Dim_PIC | pic_code | Fact_Movement_BC | pic_internal_code | 1:* | Single | Active |
| Dim_BC | bc_number | Fact_Current_BC | bc_number | 1:* | Single | Active |
| Dim_BC | bc_number | Fact_Movement_BC | bc_number | 1:* | Single | Active |
| Dim_BC | bc_number | Fact_Issue_Current | bc_number | 1:* | Single | Active |
| Dim_Date | date | Fact_Movement_BC | snapshot_date | 1:* | Single | Active |

---

## Avoid / Do Not Create

Do not create:
- Fact_Current_BC to Fact_Movement_BC
- Fact_Current_BC to Fact_Issue_Current
- Fact_Movement_BC to Fact_Issue_Current
- Control_Current_KPI to any fact
- Control_Movement_KPI to any fact
- Bidirectional filter
- Many-to-many relationship without explicit approval

---

## Optional Inactive Relationship

Optional only if needed for advanced validation:

| From Table | From Column | To Table | To Column | Cardinality | Direction | Status |
|---|---|---|---|---|---|---|
| Dim_Date | date | Fact_Current_BC | snapshot_date | 1:* | Single | Inactive / Prefer Avoid |

Reason:
- Fact_Current_BC is latest-only.
- Active date slicer can mislead KPI card behavior.

---

## Control Table Rule

Control_Current_KPI and Control_Movement_KPI must remain disconnected.

They are reconciliation baselines, not analytical facts.

---

## Validation Requirement

Before marking Phase 12 as PASS:
- no active fact-to-fact relationship
- no relationship from control tables
- no bidirectional relationship
- no uncontrolled many-to-many
- no orphan PIC key
- no orphan BC key
- Fact_Current_BC grain = one row per BC latest snapshot
- Fact_Movement_BC grain = one row per BC per snapshot_date latest run of day
