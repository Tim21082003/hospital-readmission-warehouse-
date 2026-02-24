-- ETL: Backfill behavior_id in fact_county_health_outcomes
-- Purpose:
--   • Link fact_county_health_outcomes to dim_health_behaviors using surrogate keys
--   • Populate behavior_id based on matching fips_st_cnty and year
-- Notes:
--   • Required because the initial fact load did not include behavior_id
--   • Must be run after dim_health_behaviors is fully populated
-- Version: 1.0

UPDATE fact_county_health_outcomes f
SET behavior_id = h.behavior_id
FROM dim_health_behaviors h
WHERE f.fips_st_cnty = h.fips_st_cnty
  AND f.year = h.year;
