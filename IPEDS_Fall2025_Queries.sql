-- ============================================================================
-- IPEDS Fall 2025 Enrollment Queries for Databricks
-- Data Lake: Azure Databricks
-- Generated: January 2025
--
-- IMPORTANT: Replace '2025' and '10' with appropriate year and term codes
-- Term codes: 10 = Fall, 30 = Spring, 50 = Summer (verify with your institution)
-- ============================================================================

-- ============================================================================
-- EF1: FALL ENROLLMENT BY RACE/ETHNICITY, GENDER, AND LEVEL
-- ============================================================================

-- EF1 Part A: Undergraduate students by class level, race/ethnicity, and gender
-- This query produces counts for the main EF1 enrollment grid

SELECT
    'Undergraduate' AS student_level,
    CASE
        WHEN sdm.FIRST_TIME_POST_SECONDARY = 'Y' AND sdm.TRANSFER_IN = 'N' THEN 'First-time'
        WHEN sdm.TRANSFER_IN = 'Y' THEN 'Transfer-in'
        WHEN w.degree_seeking = 'Y' THEN 'Continuing'
        ELSE 'Non-degree'
    END AS enrollment_status,
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END AS attendance_status,
    w.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2) AS ipeds_race_ethnicity,
    CASE COALESCE(err.IPEDS_REPORT_VALUE, 2)
        WHEN 1 THEN 'Nonresident alien'
        WHEN 2 THEN 'Race/ethnicity unknown'
        WHEN 3 THEN 'Hispanic/Latino'
        WHEN 4 THEN 'American Indian or Alaska Native'
        WHEN 5 THEN 'Asian'
        WHEN 6 THEN 'Black or African American'
        WHEN 7 THEN 'Native Hawaiian or Other Pacific Islander'
        WHEN 8 THEN 'White'
        WHEN 9 THEN 'Two or more races'
        ELSE 'Race/ethnicity unknown'
    END AS race_ethnicity_desc,
    COUNT(DISTINCT w.id_num) AS headcount
FROM j1.wly_ipeds w
LEFT JOIN j1.student_div_mast sdm
    ON w.id_num = sdm.ID_NUM
    AND sdm.DIV_CDE = w.div_cde
    AND sdm.IS_STUDENT_DIV_ACTIVE = 'Y'
LEFT JOIN j1.ethnic_race_report err
    ON w.id_num = err.ID_NUM
    AND err.REPORT_TYPE = 'S'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND w.div_cde IN ('UG', 'U1', 'U2', 'U3', 'U4', 'U5', 'PB', 'WM', 'SC')
GROUP BY
    CASE
        WHEN sdm.FIRST_TIME_POST_SECONDARY = 'Y' AND sdm.TRANSFER_IN = 'N' THEN 'First-time'
        WHEN sdm.TRANSFER_IN = 'Y' THEN 'Transfer-in'
        WHEN w.degree_seeking = 'Y' THEN 'Continuing'
        ELSE 'Non-degree'
    END,
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END,
    w.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2)
ORDER BY enrollment_status, attendance_status, gender, ipeds_race_ethnicity;


-- EF1 Part B: Graduate students by race/ethnicity and gender

SELECT
    'Graduate' AS student_level,
    'N/A' AS enrollment_status,
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END AS attendance_status,
    w.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2) AS ipeds_race_ethnicity,
    CASE COALESCE(err.IPEDS_REPORT_VALUE, 2)
        WHEN 1 THEN 'Nonresident alien'
        WHEN 2 THEN 'Race/ethnicity unknown'
        WHEN 3 THEN 'Hispanic/Latino'
        WHEN 4 THEN 'American Indian or Alaska Native'
        WHEN 5 THEN 'Asian'
        WHEN 6 THEN 'Black or African American'
        WHEN 7 THEN 'Native Hawaiian or Other Pacific Islander'
        WHEN 8 THEN 'White'
        WHEN 9 THEN 'Two or more races'
        ELSE 'Race/ethnicity unknown'
    END AS race_ethnicity_desc,
    COUNT(DISTINCT w.id_num) AS headcount
FROM j1.wly_ipeds w
LEFT JOIN j1.ethnic_race_report err
    ON w.id_num = err.ID_NUM
    AND err.REPORT_TYPE = 'S'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND w.div_cde = 'GR'
GROUP BY
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END,
    w.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2)
ORDER BY attendance_status, gender, ipeds_race_ethnicity;


-- EF1 Summary: Total enrollment by level and attendance status

SELECT
    CASE
        WHEN w.div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END AS student_level,
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END AS attendance_status,
    w.gender,
    COUNT(DISTINCT w.id_num) AS headcount
FROM j1.wly_ipeds w
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
GROUP BY
    CASE
        WHEN w.div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END,
    CASE w.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END,
    w.gender
ORDER BY student_level, attendance_status, gender;


-- ============================================================================
-- EF1A: RETENTION RATES (First-time students from Fall 2024 returning Fall 2025)
-- ============================================================================

WITH fall_2024_cohort AS (
    SELECT DISTINCT
        w.id_num,
        w.f_p_time,
        w.div_cde
    FROM j1.wly_ipeds w
    INNER JOIN j1.student_div_mast sdm
        ON w.id_num = sdm.ID_NUM
        AND sdm.DIV_CDE = w.div_cde
    WHERE w.yr_cde = '2024'
      AND w.trm_cde = '10'
      AND w.div_cde IN ('UG', 'U1')
      AND sdm.FIRST_TIME_POST_SECONDARY = 'Y'
      AND sdm.TRANSFER_IN = 'N'
      AND w.degree_seeking = 'Y'
),
fall_2025_enrolled AS (
    SELECT DISTINCT id_num
    FROM j1.wly_ipeds
    WHERE yr_cde = '2025'
      AND trm_cde = '10'
),
completers AS (
    SELECT DISTINCT ID_NUM
    FROM j1.degree_history
    WHERE GRADUATED = 'Y'
      AND DEGR_DATE >= '2024-08-01'
      AND DEGR_DATE < '2025-08-01'
)
SELECT
    CASE c.f_p_time
        WHEN 'F' THEN 'Full-time'
        WHEN 'P' THEN 'Part-time'
        ELSE 'Unknown'
    END AS attendance_status,
    COUNT(DISTINCT c.id_num) AS cohort_count,
    COUNT(DISTINCT CASE
        WHEN f25.id_num IS NOT NULL OR comp.ID_NUM IS NOT NULL THEN c.id_num
        END) AS retained_or_completed,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN f25.id_num IS NOT NULL OR comp.ID_NUM IS NOT NULL THEN c.id_num
            END) * 100.0 / NULLIF(COUNT(DISTINCT c.id_num), 0),
        1
    ) AS retention_rate_pct
FROM fall_2024_cohort c
LEFT JOIN fall_2025_enrolled f25 ON c.id_num = f25.id_num
LEFT JOIN completers comp ON c.id_num = comp.ID_NUM
GROUP BY c.f_p_time
ORDER BY attendance_status;


-- ============================================================================
-- EF1B: STUDENT-TO-FACULTY RATIO
-- ============================================================================

WITH student_fte AS (
    SELECT
        SUM(CASE
            WHEN f_p_time = 'F' THEN 1.0
            WHEN f_p_time = 'P' THEN COALESCE(hrs_enrld, 0) / 12.0
            ELSE 0
        END) AS total_student_fte
    FROM j1.wly_ipeds
    WHERE yr_cde = '2025'
      AND trm_cde = '10'
      AND div_cde NOT IN ('GR')
),
faculty_count AS (
    SELECT
        COUNT(DISTINCT INSTRCTR_ID_NUM) AS faculty_headcount
    FROM j1.section_master
    WHERE YR_CDE = '2025'
      AND TRM_CDE = '10'
      AND INSTRCTR_ID_NUM IS NOT NULL
      AND INSTRCTR_ID_NUM > 0
)
SELECT
    ROUND(s.total_student_fte, 0) AS undergraduate_student_fte,
    f.faculty_headcount AS instructional_faculty_count,
    ROUND(s.total_student_fte / NULLIF(f.faculty_headcount, 0), 0) AS student_to_faculty_ratio
FROM student_fte s
CROSS JOIN faculty_count f;


-- ============================================================================
-- EF1C: RESIDENCE AND MIGRATION OF FIRST-TIME FRESHMEN
-- ============================================================================

-- First-time freshmen by state of permanent residence

SELECT
    COALESCE(UPPER(a.STATE), 'Unknown') AS state_of_residence,
    COALESCE(UPPER(a.COUNTRY), 'US') AS country,
    CASE
        WHEN UPPER(a.COUNTRY) NOT IN ('US', 'USA', 'UNITED STATES', '') AND a.COUNTRY IS NOT NULL
            THEN 'Foreign Countries'
        WHEN a.STATE IS NULL OR a.STATE = ''
            THEN 'State Unknown'
        ELSE UPPER(a.STATE)
    END AS residence_category,
    COUNT(DISTINCT w.id_num) AS first_time_freshman_count
FROM j1.wly_ipeds w
INNER JOIN j1.student_div_mast sdm
    ON w.id_num = sdm.ID_NUM
    AND sdm.DIV_CDE = w.div_cde
LEFT JOIN j1.address_master a
    ON w.id_num = a.ID_NUM
    AND a.ADDR_CDE = 'PERM'
    AND a.ADDR_STS = 'A'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND w.div_cde IN ('UG', 'U1')
  AND sdm.FIRST_TIME_POST_SECONDARY = 'Y'
  AND sdm.TRANSFER_IN = 'N'
  AND w.degree_seeking = 'Y'
GROUP BY
    COALESCE(UPPER(a.STATE), 'Unknown'),
    COALESCE(UPPER(a.COUNTRY), 'US'),
    CASE
        WHEN UPPER(a.COUNTRY) NOT IN ('US', 'USA', 'UNITED STATES', '') AND a.COUNTRY IS NOT NULL
            THEN 'Foreign Countries'
        WHEN a.STATE IS NULL OR a.STATE = ''
            THEN 'State Unknown'
        ELSE UPPER(a.STATE)
    END
ORDER BY residence_category;


-- Summary: First-time freshmen by residence type
-- NOTE: Change 'WV' to your institution's state

SELECT
    CASE
        WHEN bm.CITIZENSHIP_STS = 'N' OR bm.VISA_TYPE IS NOT NULL
            THEN 'Nonresident Alien'
        WHEN UPPER(COALESCE(a.COUNTRY, 'US')) NOT IN ('US', 'USA', 'UNITED STATES', '')
            THEN 'Foreign Countries'
        WHEN a.STATE = 'WV'
            THEN 'In-State'
        WHEN a.STATE IS NOT NULL AND a.STATE != ''
            THEN 'Out-of-State'
        ELSE 'Unknown'
    END AS residence_type,
    COUNT(DISTINCT w.id_num) AS student_count
FROM j1.wly_ipeds w
INNER JOIN j1.student_div_mast sdm
    ON w.id_num = sdm.ID_NUM
    AND sdm.DIV_CDE = w.div_cde
LEFT JOIN j1.biograph_master bm ON w.id_num = bm.ID_NUM
LEFT JOIN j1.address_master a
    ON w.id_num = a.ID_NUM
    AND a.ADDR_CDE = 'PERM'
    AND a.ADDR_STS = 'A'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND w.div_cde IN ('UG', 'U1')
  AND sdm.FIRST_TIME_POST_SECONDARY = 'Y'
  AND sdm.TRANSFER_IN = 'N'
GROUP BY
    CASE
        WHEN bm.CITIZENSHIP_STS = 'N' OR bm.VISA_TYPE IS NOT NULL
            THEN 'Nonresident Alien'
        WHEN UPPER(COALESCE(a.COUNTRY, 'US')) NOT IN ('US', 'USA', 'UNITED STATES', '')
            THEN 'Foreign Countries'
        WHEN a.STATE = 'WV'
            THEN 'In-State'
        WHEN a.STATE IS NOT NULL AND a.STATE != ''
            THEN 'Out-of-State'
        ELSE 'Unknown'
    END
ORDER BY residence_type;


-- ============================================================================
-- E12: 12-MONTH ENROLLMENT (July 1, 2024 - June 30, 2025)
-- ============================================================================

-- Unduplicated headcount across Summer 2024, Fall 2024, and Spring 2025

SELECT
    CASE
        WHEN div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END AS student_level,
    COUNT(DISTINCT id_num) AS unduplicated_headcount
FROM j1.wly_ipeds
WHERE (yr_cde = '2024' AND trm_cde IN ('50', '10', '30'))
   OR (yr_cde = '2025' AND trm_cde = '30')
GROUP BY
    CASE
        WHEN div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END;


-- E12 Detailed: By level, attendance status, race/ethnicity, and gender

WITH twelve_month_students AS (
    SELECT DISTINCT
        w.id_num,
        w.gender,
        w.div_cde,
        MAX(CASE WHEN w.f_p_time = 'F' THEN 1 ELSE 0 END) AS was_full_time
    FROM j1.wly_ipeds w
    WHERE (w.yr_cde = '2024' AND w.trm_cde IN ('50', '10', '30'))
       OR (w.yr_cde = '2025' AND w.trm_cde = '30')
    GROUP BY w.id_num, w.gender, w.div_cde
)
SELECT
    CASE
        WHEN t.div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END AS student_level,
    CASE
        WHEN t.was_full_time = 1 THEN 'Full-time'
        ELSE 'Part-time'
    END AS attendance_status,
    t.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2) AS ipeds_race_ethnicity,
    CASE COALESCE(err.IPEDS_REPORT_VALUE, 2)
        WHEN 1 THEN 'Nonresident alien'
        WHEN 2 THEN 'Race/ethnicity unknown'
        WHEN 3 THEN 'Hispanic/Latino'
        WHEN 4 THEN 'American Indian or Alaska Native'
        WHEN 5 THEN 'Asian'
        WHEN 6 THEN 'Black or African American'
        WHEN 7 THEN 'Native Hawaiian or Other Pacific Islander'
        WHEN 8 THEN 'White'
        WHEN 9 THEN 'Two or more races'
        ELSE 'Race/ethnicity unknown'
    END AS race_ethnicity_desc,
    COUNT(DISTINCT t.id_num) AS headcount
FROM twelve_month_students t
LEFT JOIN j1.ethnic_race_report err
    ON t.id_num = err.ID_NUM
    AND err.REPORT_TYPE = 'S'
GROUP BY
    CASE
        WHEN t.div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END,
    CASE
        WHEN t.was_full_time = 1 THEN 'Full-time'
        ELSE 'Part-time'
    END,
    t.gender,
    COALESCE(err.IPEDS_REPORT_VALUE, 2)
ORDER BY student_level, attendance_status, gender, ipeds_race_ethnicity;


-- E12 Instructional Activity (Credit Hours)

SELECT
    CASE
        WHEN div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END AS student_level,
    SUM(COALESCE(hrs_enrld, 0)) AS total_credit_hours
FROM j1.wly_ipeds
WHERE (yr_cde = '2024' AND trm_cde IN ('50', '10', '30'))
   OR (yr_cde = '2025' AND trm_cde = '30')
GROUP BY
    CASE
        WHEN div_cde = 'GR' THEN 'Graduate'
        ELSE 'Undergraduate'
    END;


-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Validation 1: Students missing IPEDS race/ethnicity
SELECT
    COUNT(DISTINCT w.id_num) AS students_missing_ipeds_race
FROM j1.wly_ipeds w
LEFT JOIN j1.ethnic_race_report err
    ON w.id_num = err.ID_NUM
    AND err.REPORT_TYPE = 'S'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND err.ID_NUM IS NULL;


-- Validation 2: Students missing gender
SELECT
    COUNT(DISTINCT id_num) AS students_missing_gender
FROM j1.wly_ipeds
WHERE yr_cde = '2025'
  AND trm_cde = '10'
  AND (gender IS NULL OR gender = '' OR gender NOT IN ('M', 'F'));


-- Validation 3: First-time freshman count
SELECT
    'First-time Freshmen' AS validation_check,
    COUNT(DISTINCT w.id_num) AS student_count
FROM j1.wly_ipeds w
INNER JOIN j1.student_div_mast sdm
    ON w.id_num = sdm.ID_NUM
    AND sdm.DIV_CDE = w.div_cde
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
  AND w.div_cde IN ('UG', 'U1')
  AND sdm.FIRST_TIME_POST_SECONDARY = 'Y'
  AND sdm.TRANSFER_IN = 'N';


-- Validation 4: Year-over-year enrollment comparison
SELECT
    yr_cde,
    trm_cde,
    COUNT(DISTINCT id_num) AS total_enrollment
FROM j1.wly_ipeds
WHERE trm_cde = '10'
  AND yr_cde IN ('2023', '2024', '2025')
GROUP BY yr_cde, trm_cde
ORDER BY yr_cde;


-- Validation 5: Division code distribution
SELECT
    div_cde,
    COUNT(DISTINCT id_num) AS student_count
FROM j1.wly_ipeds
WHERE yr_cde = '2025'
  AND trm_cde = '10'
GROUP BY div_cde
ORDER BY student_count DESC;


-- Validation 6: Race/ethnicity distribution
SELECT
    COALESCE(err.IPEDS_REPORT_VALUE, 2) AS ipeds_race,
    CASE COALESCE(err.IPEDS_REPORT_VALUE, 2)
        WHEN 1 THEN 'Nonresident alien'
        WHEN 2 THEN 'Race unknown'
        WHEN 3 THEN 'Hispanic'
        WHEN 4 THEN 'Am Indian/AK Native'
        WHEN 5 THEN 'Asian'
        WHEN 6 THEN 'Black/African Am'
        WHEN 7 THEN 'Native HI/Pac Isl'
        WHEN 8 THEN 'White'
        WHEN 9 THEN 'Two or more'
        ELSE 'Unknown'
    END AS race_desc,
    COUNT(DISTINCT w.id_num) AS headcount
FROM j1.wly_ipeds w
LEFT JOIN j1.ethnic_race_report err
    ON w.id_num = err.ID_NUM
    AND err.REPORT_TYPE = 'S'
WHERE w.yr_cde = '2025'
  AND w.trm_cde = '10'
GROUP BY COALESCE(err.IPEDS_REPORT_VALUE, 2)
ORDER BY ipeds_race;


-- ============================================================================
-- END OF IPEDS FALL 2025 ENROLLMENT QUERIES
-- ============================================================================
