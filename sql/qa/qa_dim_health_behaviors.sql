-- QA: dim_health_behaviors
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of the health behaviors dimension
--   • Ensure no invalid percentages, missing required fields, or duplicate county-year rows
--   • Confirm referential integrity with dim_geography
-- Version: 1.0

------------------------------------------------------------
-- Row count
------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM dim_health_behaviors;

------------------------------------------------------------
-- Year range check
------------------------------------------------------------
SELECT MIN(year) AS min_year, MAX(year) AS max_year
FROM dim_health_behaviors;

------------------------------------------------------------
-- FIPS range sanity check
------------------------------------------------------------
SELECT MIN(fips_st_cnty) AS min_fips, MAX(fips_st_cnty) AS max_fips
FROM dim_health_behaviors;

------------------------------------------------------------
-- Duplicate county-year rows
------------------------------------------------------------
SELECT fips_st_cnty, year, COUNT(*)
FROM dim_health_behaviors
GROUP BY fips_st_cnty, year
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- Missing required fields
------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE smoking_pct IS NULL) AS smoking_nulls,
    COUNT(*) FILTER (WHERE obesity_pct IS NULL) AS obesity_nulls,
    COUNT(*) FILTER (WHERE physical_inactivity_pct IS NULL) AS physical_inactivity_nulls,
    COUNT(*) FILTER (WHERE diabetes_pct IS NULL) AS diabetes_nulls,
    COUNT(*) FILTER (WHERE binge_drinking_pct IS NULL) AS binge_drinking_nulls,
    COUNT(*) FILTER (WHERE poor_mental_health_pct IS NULL) AS poor_mental_health_nulls,
    COUNT(*) FILTER (WHERE no_routine_checkup_pct IS NULL) AS no_routine_checkup_nulls
FROM dim_health_behaviors;

------------------------------------------------------------
-- Invalid percentage values (should be 0–100)
------------------------------------------------------------
SELECT *
FROM dim_health_behaviors
WHERE smoking_pct < 0 OR smoking_pct > 100
   OR obesity_pct < 0 OR obesity_pct > 100
   OR physical_inactivity_pct < 0 OR physical_inactivity_pct > 100
   OR diabetes_pct < 0 OR diabetes_pct > 100
   OR binge_drinking_pct < 0 OR binge_drinking_pct > 100
   OR poor_mental_health_pct < 0 OR poor_mental_health_pct > 100
   OR no_routine_checkup_pct < 0 OR no_routine_checkup_pct > 100;

------------------------------------------------------------
-- Referential integrity: behaviors must match geography
------------------------------------------------------------
SELECT h.fips_st_cnty
FROM dim_health_behaviors h
LEFT JOIN dim_geography g
    ON h.fips_st_cnty = g.fips_st_cnty
WHERE g.fips_st_cnty IS NULL;
