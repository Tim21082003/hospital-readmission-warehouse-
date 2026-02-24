-- QA: dim_hospital
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of hospital dimension
--   • Check FIPS assignment, star ratings, ownership, and emergency services distribution
--   • Identify duplicate facilities and missing key attributes
-- Version: 1.0

-- Row count
SELECT COUNT(*) AS hospital_count
FROM dim_hospital;

-- Missing FIPS
SELECT COUNT(*) AS missing_fips
FROM dim_hospital
WHERE fips_st_cnty IS NULL;

-- Missing star ratings
SELECT COUNT(*) AS missing_star_rating
FROM dim_hospital
WHERE overall_star_rating IS NULL;

-- Emergency services distribution
SELECT emergency_services, COUNT(*)
FROM dim_hospital
GROUP BY emergency_services
ORDER BY emergency_services;

-- Hospital type distribution
SELECT hospital_type, COUNT(*)
FROM dim_hospital
GROUP BY hospital_type
ORDER BY COUNT(*) DESC;

-- Ownership distribution
SELECT hospital_ownership, COUNT(*)
FROM dim_hospital
GROUP BY hospital_ownership
ORDER BY COUNT(*) DESC;

-- Missing readmission measure counts
SELECT
    SUM(CASE WHEN readm_measure_count IS NULL THEN 1 ELSE 0 END) AS missing_readm_count,
    SUM(CASE WHEN readm_measures_better IS NULL THEN 1 ELSE 0 END) AS missing_better,
    SUM(CASE WHEN readm_measures_no_diff IS NULL THEN 1 ELSE 0 END) AS missing_no_diff,
    SUM(CASE WHEN readm_measures_worse IS NULL THEN 1 ELSE 0 END) AS missing_worse
FROM dim_hospital;

-- Duplicate facilities (full address match)
SELECT facility_name, address, state, zip_code, COUNT(*)
FROM dim_hospital
GROUP BY facility_name, address, state, zip_code
HAVING COUNT(*) > 1;

-- Duplicate facility names (different addresses)
SELECT facility_name, COUNT(*)
FROM dim_hospital
GROUP BY facility_name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Remaining missing FIPS (detailed)
SELECT facility_id, facility_name, address, city, state, zip_code
FROM dim_hospital
WHERE fips_st_cnty IS NULL
ORDER BY state, zip_code, facility_name;
