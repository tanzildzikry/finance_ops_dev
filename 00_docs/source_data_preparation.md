# Source Data Preparation — Finance Ops Dev

## Purpose

This document controls the preparation of masked source data before loading into PostgreSQL raw tables.

The goal is to make sure that source files used for development are safe, structured, and aligned with the real project mapping.

---

## Current Phase

Phase: Phase 4 — Source / Masked Data Preparation  
Status: IN PROGRESS  

---

## Data Policy

This project uses masked or synthetic data only inside the GitHub repository.

Real operational data must stay outside this repository.

Allowed source data in repository:

- Masked CSV
- Masked Excel
- Synthetic sample data
- Data dictionary
- Column mapping documentation

Not allowed source data in repository:

- Real operational CSV
- Real operational Excel
- Real customer name
- Real PIC name if sensitive
- Real invoice number
- Credentials
- Database dump
- Raw production export
- Power BI PBIX with embedded real data

---

## Approved Folder

The only approved folder for masked sample data is:

```text
03_sample_data_masked/