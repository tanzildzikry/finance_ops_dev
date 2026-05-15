# Finance_Ops_Dev — Project Memory

Last Updated: 2026-05-15

## Active Project Mode

Finance_Ops_Project Mode

## Active Phase

Phase 12 — Power BI Semantic Model Build / Relationship Setup

## Current Memory Update

The project has approved a Phase 12 semantic model refactor.

Rules now active:
- Use terminal-first / script-first documentation patching.
- Avoid manual copy-editing repository files for major updates.
- Keep progress_log.md cumulative from Phase 0.
- Use Python-first file generation.
- Write UTF-8 without BOM.
- Use curated reporting views for Power BI.
- Do not load raw, clean fact, snapshot base, or issue base tables into main PBIX model.
- Keep KPI control tables disconnected.
- Use canonical DAX measures only.
- Avoid redundant by-PIC, by-customer, by-division measures.
- Movement trend is not meaningful until latest-per-day distinct_snapshot_dates >= 2.

## Current Semantic Model Baseline

Power BI model:
- Dim_Date
- Dim_PIC
- Dim_BC
- Fact_Current_BC
- Fact_Movement_BC
- Fact_Issue_Current
- Control_Current_KPI
- Control_Movement_KPI
- _Measures

## Current DAX Baseline

Use prefixes:
- Current
- Control
- Recon
- Movement

Do not use billing_status <> "BILLED" as open backlog logic.
Use is_open_unbilled and open_rab_exposure_amount.
