-- ETL: Backfill benes_ffs_cnt in fact_county_health_outcomes
-- Purpose:
--   • Populate Medicare FFS beneficiary counts using the 2014_medicare_fee dataset
--   • Apply regex validation to avoid casting errors from non-numeric values
--   • Update only rows where the county-year matches
-- Notes:
--   • Required because the initial fact load did not include benes_ffs_cnt
--   • Must be run after the column exists in fact_county_health_outcomes
-- Version: 1.0

UPDATE fact_county_health_outcomes AS fcho
SET benes_ffs_cnt = CASE
    WHEN fee."BENES_FFS_CNT" ~ '^[0-9]+$' THEN fee."BENES_FFS_CNT"::INTEGER
    ELSE NULL
END
FROM "2014_medicare_fee" AS fee
WHERE fcho.fips_st_cnty = fee."BENE_GEO_CD"
  AND fcho.year = fee."YEAR";
