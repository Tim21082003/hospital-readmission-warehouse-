-- QA: fact_county_health_outcomes
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of the county-level fact table
--   • Ensure all counties have a row for the target year (2023)
--   • Check for missing Medicare, CHR, provider access, and HRRP metrics
--   • Validate PQI ranges, spending ranges, and outliers
--   • Confirm referential integrity with dim_geography
-- Version: 1.0

------------------------------------------------------------
-- Row count for 2023
------------------------------------------------------------
SELECT COUNT(*) AS row_count
FROM fact_county_health_outcomes
WHERE year = 2023;

------------------------------------------------------------
-- Compare to geography row count
------------------------------------------------------------
SELECT COUNT(*) AS geography_rows
FROM dim_geography;

------------------------------------------------------------
-- Counties missing from the fact table
------------------------------------------------------------
SELECT g.fips_st_cnty
FROM dim_geography g
LEFT JOIN fact_county_health_outcomes f
  ON f.fips_st_cnty = g.fips_st_cnty
 AND f.year = 2023
WHERE f.fips_st_cnty IS NULL;

------------------------------------------------------------
-- Missing Medicare metrics
------------------------------------------------------------
SELECT COUNT(*) AS medicare_nulls
FROM fact_county_health_outcomes
WHERE year = 2023
  AND (
        er_visits_per_1000_benes IS NULL OR
        tot_mdcr_stdzd_pymt_pc IS NULL OR
        ip_cvrd_stays_per_1000_benes IS NULL
      );

------------------------------------------------------------
-- Missing CHR metrics
------------------------------------------------------------
SELECT COUNT(*) AS chr_nulls
FROM fact_county_health_outcomes
WHERE year = 2023
  AND (
        poverty_pct IS NULL OR
        uninsured_pct IS NULL OR
        unemployment_pct IS NULL
      );

------------------------------------------------------------
-- Missing provider access metrics
------------------------------------------------------------
SELECT COUNT(*) AS provider_nulls
FROM fact_county_health_outcomes
WHERE year = 2023
  AND (
        primary_care_physicians_rate IS NULL OR
        mental_health_provider_rate IS NULL OR
        dentist_rate IS NULL
      );

------------------------------------------------------------
-- Missing HRRP metrics
------------------------------------------------------------
SELECT COUNT(*) AS hrrp_nulls
FROM fact_county_health_outcomes
WHERE year = 2023
  AND total_readmissions IS NULL;

------------------------------------------------------------
-- Medicare spending range
------------------------------------------------------------
SELECT 
    MIN(tot_mdcr_stdzd_pymt_pc) AS min_spending,
    MAX(tot_mdcr_stdzd_pymt_pc) AS max_spending
FROM fact_county_health_outcomes
WHERE year = 2023;

------------------------------------------------------------
-- Counties with missing Medicare metrics (detailed)
------------------------------------------------------------
SELECT 
    fips_st_cnty,
    er_visits_per_1000_benes,
    tot_mdcr_stdzd_pymt_pc,
    ip_cvrd_stays_per_1000_benes
FROM fact_county_health_outcomes
WHERE year = 2023
  AND (
        er_visits_per_1000_benes IS NULL OR
        tot_mdcr_stdzd_pymt_pc IS NULL OR
        ip_cvrd_stays_per_1000_benes IS NULL
      )
ORDER BY fips_st_cnty;

------------------------------------------------------------
-- ER visits range
------------------------------------------------------------
SELECT 
    MIN(er_visits_per_1000_benes),
    MAX(er_visits_per_1000_benes)
FROM fact_county_health_outcomes
WHERE year = 2023;

------------------------------------------------------------
-- PQI ranges
------------------------------------------------------------
SELECT 
    MIN(pqi_chf_75plus),
    MAX(pqi_chf_75plus)
FROM fact_county_health_outcomes
WHERE year = 2023;

------------------------------------------------------------
-- Poverty percentage range
------------------------------------------------------------
SELECT 
    MIN(poverty_pct),
    MAX(poverty_pct)
FROM fact_county_health_outcomes
WHERE year = 2023;

------------------------------------------------------------
-- Spending distribution (bucketed)
------------------------------------------------------------
SELECT 
    ROUND(tot_mdcr_stdzd_pymt_pc, -2) AS bucket,
    COUNT(*)
FROM fact_county_health_outcomes
WHERE year = 2023
GROUP BY bucket
ORDER BY bucket;

------------------------------------------------------------
-- PQI values present (sanity check)
------------------------------------------------------------
SELECT f.fips_st_cnty, f.year,
       f.pqi_chf_75plus,
       f.pqi_copd_75plus,
       f.pqi_diabetes_75plus,
       f.pqi_hypertension_75plus,
       f.pqi_pneumonia_75plus,
       f.pqi_uti_75plus
FROM fact_county_health_outcomes f
WHERE f.pqi_chf_75plus IS NOT NULL
   OR f.pqi_copd_75plus IS NOT NULL
   OR f.pqi_diabetes_75plus IS NOT NULL
   OR f.pqi_hypertension_75plus IS NOT NULL
   OR f.pqi_pneumonia_75plus IS NOT NULL
   OR f.pqi_uti_75plus IS NOT NULL
ORDER BY f.fips_st_cnty, f.year;

------------------------------------------------------------
-- benes_ffs_cnt completeness
------------------------------------------------------------
SELECT COUNT(*) AS total_rows,
       COUNT(benes_ffs_cnt) AS populated_rows,
       COUNT(*) - COUNT(benes_ffs_cnt) AS null_rows
FROM fact_county_health_outcomes;

------------------------------------------------------------
-- Invalid benes_ffs_cnt values
------------------------------------------------------------
SELECT *
FROM fact_county_health_outcomes
WHERE benes_ffs_cnt < 0
   OR benes_ffs_cnt > 1000000;

------------------------------------------------------------
-- Random sample comparison to Medicare source
------------------------------------------------------------
SELECT fcho.fips_st_cnty,
       fcho.benes_ffs_cnt,
       fee."BENES_FFS_CNT" AS source_value
FROM fact_county_health_outcomes fcho
JOIN "2014_medicare_fee" fee
  ON fcho.fips_st_cnty = fee."BENE_GEO_CD"
 AND fcho.year = fee."YEAR"
ORDER BY RANDOM()
LIMIT 10;
