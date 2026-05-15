# Finance_Ops_Dev — Decision Log

Last Updated: 2026-05-15

## Decision — Phase 12 Semantic Model Refactor

Status: APPROVED DESIGN BASELINE

Decision:
- Use curated reporting views as Power BI contract.
- Keep backend raw, clean, and snapshot layers for audit and pipeline only.
- Load only curated Fact, Dim, and Control tables into Power BI.
- Keep Control_Current_KPI and Control_Movement_KPI disconnected.
- Avoid active fact-to-fact relationships.
- Use Dim_BC to support drill-through and issue detail relationships.
- Keep Dim_Date active to movement fact only.
- Avoid active Dim_Date relationship to latest/current fact.
- Use canonical minimal DAX measure set.
- Do not create by-PIC, by-customer, or by-division measures.

Reason:
- Reduce ambiguity below 3%.
- Reduce redundant measure risk below 2%.
- Improve semantic model maintainability.
- Keep KPI reconciliation auditable.

Validation:
- NEEDS REVIEW until implemented and reconciled in PBIX.
