-- QA: dim_provider_access
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of the provider access dimension
--   • Ensure no invalid rates, missing population values, or duplicate county-year rows
--   • Confirm referential integrity with dim_geography
--   • Validate alignment with AHRF source data
-- Version: 1.0

------------------------------------------------------------
-- Row count for 2023
------------------------------------------------------------
SELECT COUNT(*) AS provider_access_rows
FROM dim_provider_access
WHERE year = 2023;

------------------------------------------------------------
-- Compare to AHRF source row count
------------------------------------------------------------
SELECT COUNT(*) AS ahrf_rows
FROM ahrf2025_cleaned
WHERE year = 2023;

------------------------------------------------------------
-- Year distribution
------------------------------------------------------------
SELECT year, COUNT(*)
FROM dim_provider_access
GROUP BY year
ORDER BY year;

------------------------------------------------------------
-- Duplicate county-year rows
------------------------------------------------------------
SELECT fips_st_cnty, year, COUNT(*)
FROM dim_provider_access
GROUP BY fips_st_cnty, year
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- Referential integrity: provider access must match geography
------------------------------------------------------------
SELECT p.fips_st_cnty
FROM dim_provider_access p
LEFT JOIN dim_geography g
  ON p.fips_st_cnty = g.fips_st_cnty
WHERE g.fips_st_cnty IS NULL;

------------------------------------------------------------
-- Missing population
------------------------------------------------------------
SELECT COUNT(*) AS missing_population
FROM dim_provider_access
WHERE population IS NULL;

------------------------------------------------------------
-- Missing provider access metrics
------------------------------------------------------------
SELECT
    SUM(CASE WHEN primary_care_physicians_rate IS NULL THEN 1 END) AS missing_primary_care,
    SUM(CASE WHEN mental_health_provider_rate IS NULL THEN 1 END) AS missing_mental_health,
    SUM(CASE WHEN dentist_rate IS NULL THEN 1 END) AS missing_dentists,
    SUM(CASE WHEN specialist_physicians_rate IS NULL THEN 1 END) AS missing_specialists,
    SUM(CASE WHEN hospital_beds_per_1000 IS NULL THEN 1 END) AS missing_beds,
    SUM(CASE WHEN rn_supply_rate IS NULL THEN 1 END) AS missing_rn,
    SUM(CASE WHEN lpn_supply_rate IS NULL THEN 1 END) AS missing_lpn
FROM dim_provider_access;

------------------------------------------------------------
-- Invalid (negative) values
------------------------------------------------------------
SELECT *
FROM dim_provider_access
WHERE primary_care_physicians_rate < 0
   OR mental_health_provider_rate < 0
   OR dentist_rate < 0
   OR specialist_physicians_rate < 0
   OR hospital_beds_per_1000 < 0
   OR rn_supply_rate < 0
   OR lpn_supply_rate < 0;

------------------------------------------------------------
-- Unexpected years (should be only 2023)
------------------------------------------------------------
SELECT DISTINCT year
FROM dim_provider_access
WHERE year <> 2023;

------------------------------------------------------------
-- Geography rows missing provider access
------------------------------------------------------------
SELECT g.fips_st_cnty
FROM dim_geography g
LEFT JOIN dim_provider_access p
  ON g.fips_st_cnty = p.fips_st_cnty
WHERE p.fips_st_cnty IS NULL;

------------------------------------------------------------
-- Duplicate FIPS for 2023
------------------------------------------------------------
SELECT fips_st_cnty, COUNT(*)
FROM dim_provider_access
WHERE year = 2023
GROUP BY fips_st_cnty
HAVING COUNT(*) > 1;
