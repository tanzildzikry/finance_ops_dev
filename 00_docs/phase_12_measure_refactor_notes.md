# Phase 12 Measure Refactor Notes — Finance_Ops_Dev

## Status

Phase: 12  
Status: IN PROGRESS  
Validation Result: NEEDS REVIEW  
Risk Level: LOW  

---

## Objective

Reduce DAX ambiguity and redundant measures.

Target:
- measure ambiguity below 3%
- redundant measure risk below 2%
- DAX complexity LOW

---

## Canonical Measure Rule

Use only canonical measures.

Do not create duplicate synonyms.

Do not create measures only for visual context such as:
- by PIC
- by customer
- by division

Dimension breakdown must come from relationship filter context.

---

## Required Prefixes

Use these prefixes:

- Current ...
- Control ...
- Recon ...
- Movement ...

---

## Current KPI Measures

Canonical current measures:
- Current Total BC Count
- Current Open BC Count
- Current Open RAB Exposure
- Current High Risk BC Count
- Current High Risk RAB Exposure
- Current Reported Excluded BC Count
- Current UNCLASSIFIED PIC Count
- Current Manual Review BC Count
- Current Average Aging Open BC

---

## Control KPI Measures

Control measures:
- Control Total BC Count
- Control Open BC Count
- Control Open RAB Exposure
- Control High Risk BC Count
- Control High Risk RAB Exposure
- Control Reported Excluded BC Count
- Control UNCLASSIFIED PIC Count
- Control Manual Review BC Count
- Control Average Aging Open BC

Control table must be disconnected.

---

## Reconciliation Measures

Minimal reconciliation measures:
- Recon Open BC Diff
- Recon Open RAB Diff
- Recon High Risk BC Diff
- Recon Average Aging Diff
- Recon KPI Status

---

## Movement Guardrail Measures

Required movement measures:
- Movement Readiness Flag
- Movement Readiness Status

Do not create full movement insight measures until latest-per-day distinct_snapshot_dates >= 2.

---

## Measures Not Allowed in Phase 12

Do not create:
- Open BC Count by PIC
- Open RAB Exposure by PIC
- PIC Open RAB Exposure
- PIC High Risk Count
- Open BC by Customer
- Open Exposure by Division
- Total Open Backlog
- Open Backlog Amount
- Unbilled Amount
- Actual Cashflow
- DSO
- Collection Performance
- Payment Overdue Final

---

## Open Backlog Rule

Use:
- is_open_unbilled
- open_rab_exposure_amount

Do not use:
- billing_status <> "BILLED"

---

## UNCLASSIFIED Rule

UNCLASSIFIED is a correction bucket.

It is not a PIC performance penalty.

---

## Status

This refactor is approved as Phase 12 design baseline.

Final PASS requires PBIX implementation and SQL-vs-Power BI reconciliation.
