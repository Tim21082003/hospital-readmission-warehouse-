-- ETL: Backfill socio_id in fact_county_health_outcomes
-- Purpose:
--   • Link fact_county_health_outcomes to dim_socioeconomic using surrogate keys
--   • Populate socio_id based on matching fips_st_cnty and year
-- Notes:
--   • Must be run after dim_socioeconomic is fully loaded for the target year
--   • Ensures referential integrity between fact and dimension

-- This update is required because the initial fact load did not include socio_id.
-- The socioeconomic dimension was loaded afterward, so this script backfills the FK.

-- Version: 1.0

UPDATE fact_county_health_outcomes f
SET socio_id = s.socio_id
FROM dim_socioeconomic s
WHERE f.fips_st_cnty = s.fips_st_cnty
  AND f.year = s.year;
