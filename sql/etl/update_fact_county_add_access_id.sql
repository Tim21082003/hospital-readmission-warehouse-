-- ETL: Backfill access_id in fact_county_health_outcomes
-- Purpose:
--   • Link fact_county_health_outcomes to dim_provider_access using surrogate keys
--   • Populate access_id based on matching fips_st_cnty and year
-- Notes:
--   • Required because the initial fact load did not include access_id
--   • Must be run after dim_provider_access is fully populated for the target year
-- Version: 1.0

UPDATE fact_county_health_outcomes f
SET access_id = p.access_id
FROM dim_provider_access p
WHERE f.fips_st_cnty = p.fips_st_cnty
  AND f.year = p.year;
