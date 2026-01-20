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

1. **Year/Term Codes:** Replace `'2025'` and `'10'` with appropriate values
   - Term codes: `10` = Fall, `30` = Spring, `50` = Summer
2. **Institution State:** Change `'WV'` to your institution's state in the residence query
3. **Address Code:** Verify `'PERM'` is correct for permanent addresses

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

## Timeline Reference

| Phase | Timeframe |
|-------|-----------|
| Census Date | September 2025 |
| Data Collection | October 2025 |
| IPEDS Submission | November - December 2025 |
