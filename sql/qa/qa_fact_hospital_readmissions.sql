-- QA: fact_hospital_readmissions
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of the HRRP fact table
--   • Ensure all rows have surrogate keys, FIPS, and required readmission metrics
--   • Check for duplicate facility-measure-year combinations
--   • Validate measure distributions and identify missing or invalid values
-- Version: 1.0

------------------------------------------------------------
-- Row count
------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM fact_hospital_readmissions;

------------------------------------------------------------
-- Missing surrogate keys
------------------------------------------------------------
SELECT COUNT(*) AS missing_hospital_key
FROM fact_hospital_readmissions
WHERE hospital_key IS NULL;

------------------------------------------------------------
-- Missing FIPS
------------------------------------------------------------
SELECT COUNT(*) AS missing_fips
FROM fact_hospital_readmissions
WHERE fips_st_cnty IS NULL;

------------------------------------------------------------
-- Duplicate facility-measure-year rows
------------------------------------------------------------
SELECT facility_id, measure_name, year, COUNT(*) AS row_count
FROM fact_hospital_readmissions
GROUP BY facility_id, measure_name, year
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- Missing readmission metrics
------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE excess_readmission_ratio IS NULL) AS null_excess_ratio,
    COUNT(*) FILTER (WHERE predicted_readmission_rate IS NULL) AS null_predicted_rate,
    COUNT(*) FILTER (WHERE expected_readmission_rate IS NULL) AS null_expected_rate,
    COUNT(*) FILTER (WHERE number_of_readmissions IS NULL) AS null_readmissions
FROM fact_hospital_readmissions;

------------------------------------------------------------
-- Random sample of joined hospital + fact rows
------------------------------------------------------------
SELECT *
FROM fact_hospital_readmissions
WHERE facility_id IN (
    SELECT facility_id
    FROM dim_hospital
    ORDER BY RANDOM()
    LIMIT 5
)
LIMIT 50;

------------------------------------------------------------
-- Measure distribution
------------------------------------------------------------
SELECT measure_name, COUNT(*) AS rows
FROM fact_hospital_readmissions
GROUP BY measure_name
ORDER BY rows DESC;
