-- DDL: Add unique constraint to fact_county_health_outcomes
-- Purpose:
--   • Enforce the natural grain of the fact table (one row per county per year)
--   • Prevent duplicate loads or accidental reprocessing
--   • Strengthen referential integrity with county-level dimensions
-- Notes:
--   • Must be applied after the initial fact load and backfill updates
-- Version: 1.0

ALTER TABLE fact_county_health_outcomes
ADD CONSTRAINT fact_county_health_outcomes_uniq
UNIQUE (fips_st_cnty, year);
