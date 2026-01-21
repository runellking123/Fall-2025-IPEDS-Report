# Fall 2025 IPEDS Report

SQL queries for generating IPEDS Fall Enrollment report data from Databricks.

## Overview

This repository contains SQL queries for extracting IPEDS (Integrated Postsecondary Education Data System) Fall Enrollment data from the Databricks Data Lake.

## IPEDS Components Included

| Component | Description |
|-----------|-------------|
| **EF1** | Fall enrollment by race/ethnicity, gender, and level |
| **EF1A** | Retention rates (Fall 2024 → Fall 2025 cohort tracking) |
| **EF1B** | Student-to-faculty ratio |
| **EF1C** | Residence and migration of first-time freshmen |
| **E12** | 12-month unduplicated enrollment |

## Data Source

- **Platform:** Azure Databricks
- **Schema:** `j1`
- **Key Tables:**
  - `j1.wly_ipeds` - Main enrollment view
  - `j1.student_div_mast` - Student division master (first-time/transfer flags)
  - `j1.ethnic_race_report` - IPEDS race/ethnicity values
  - `j1.address_master` - Student addresses for residency
  - `j1.biograph_master` - Biographical data (citizenship)
  - `j1.section_master` - Course sections (faculty data)
  - `j1.degree_history` - Degree completions

## Configuration

Before running the queries, update the following:

1. **Year/Term Codes:** Currently set to `'2025'` and `'10'` (Fall 2025)
   - Term codes: `10` = Fall, `30` = Spring, `50` = Summer
2. **Institution State:** Set to `'TX'` (Texas) for in-state/out-of-state classification
3. **Address Code:** Set to `'PERM'` for permanent addresses

## IPEDS Race/Ethnicity Mapping

| Code | Description |
|------|-------------|
| 1 | Nonresident alien |
| 2 | Race/ethnicity unknown |
| 3 | Hispanic/Latino |
| 4 | American Indian or Alaska Native |
| 5 | Asian |
| 6 | Black or African American |
| 7 | Native Hawaiian or Other Pacific Islander |
| 8 | White |
| 9 | Two or more races |

## Validation Queries

The file includes 6 validation queries to ensure data quality:
1. Students missing IPEDS race/ethnicity
2. Students missing gender
3. First-time freshman count verification
4. Year-over-year enrollment comparison
5. Division code distribution
6. Race/ethnicity distribution

## Usage

Run queries directly in Databricks SQL Editor or via ODBC connection.

## IPEDS 2025-26 Data Collection Schedule

IPEDS collects data in three collection periods. **Fall Enrollment (EF)** and **12-Month Enrollment (E12)** are submitted in different collection periods:

### Fall Collection Period (September - October 2025)
Components: Institutional Characteristics (IC), Completions (C), **12-Month Enrollment (E12)**

| Milestone | Date |
|-----------|------|
| Registration Opens | August 6, 2025 |
| Collection Opens | ~September 3, 2025 |
| Keyholder Deadline | ~October 15, 2025 |
| Coordinator Deadline | ~October 29, 2025 |

### Winter Collection Period (December 2025 - February 2026)
Components: Student Financial Aid (SFA), Graduation Rates (GR/GR200), Outcome Measures (OM), Admissions (ADM)

| Milestone | Date |
|-----------|------|
| Collection Opens | ~December 3, 2025 |
| Keyholder Deadline | ~February 11, 2026 |
| Coordinator Deadline | ~February 25, 2026 |

### Spring Collection Period (December 2025 - April 2026)
Components: **Fall Enrollment (EF)**, Finance (F), Human Resources (HR), Academic Libraries (AL), ACTS

| Milestone | Date |
|-----------|------|
| Collection Opens | ~December 3, 2025 |
| ACTS Opens | December 18, 2025 |
| ACTS Keyholder Deadline | March 18, 2026 |
| Keyholder Deadline | ~April 1, 2026 |
| Coordinator Deadline | ~April 15, 2026 |

### Internal Timeline for Fall 2025 Data

| Phase | Timeframe |
|-------|-----------|
| Census Date (Fall 2025) | September 2025 |
| Data Preparation & Validation | September - November 2025 |
| E12 Submission (Fall Collection) | September - October 2025 |
| EF Submission (Spring Collection) | December 2025 - April 2026 |

> **Note:** Dates marked with ~ are estimates based on historical patterns. Confirm exact dates at [IPEDS Data Collection Schedule](https://surveys.nces.ed.gov/ipeds/public/data-collection-schedule).

## Resources

- [IPEDS Data Collection Schedule](https://surveys.nces.ed.gov/ipeds/public/data-collection-schedule)
- [2025-26 Keyholder Handbook](https://surveys.nces.ed.gov/ipeds/public/keyholder-handbook)
- [Summary of Changes to 2025-26 Collection](https://surveys.nces.ed.gov/ipeds/public/changes-to-the-current-year)
- [NCES IPEDS Homepage](https://nces.ed.gov/ipeds)
