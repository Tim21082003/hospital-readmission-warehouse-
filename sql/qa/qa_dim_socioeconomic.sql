-- QA: dim_socioeconomic
-- Purpose:
--   • Validate completeness, uniqueness, and data quality of the socioeconomic dimension
--   • Ensure CHR percentages are valid (0–100), SVI values are valid (0–1)
--   • Confirm no duplicate county-year rows
--   • Validate referential integrity with dim_geography
--   • Identify missing CHR or SVI source rows
-- Version: 1.0

------------------------------------------------------------
-- Duplicate county-year rows
------------------------------------------------------------
SELECT fips_st_cnty, year, COUNT(*)
FROM dim_socioeconomic
GROUP BY fips_st_cnty, year
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- Invalid CHR percentage values (should be 0–100)
------------------------------------------------------------
SELECT fips,
       children_in_poverty,
       unemployed_1,
       uninsured_1,
       households_with_broadband_access_pct
FROM population_health_and_well_being_cleaned
WHERE children_in_poverty NOT BETWEEN 0 AND 100
   OR unemployed_1 NOT BETWEEN 0 AND 100
   OR uninsured_1 NOT BETWEEN 0 AND 100
   OR households_with_broadband_access_pct NOT BETWEEN 0 AND 100;

------------------------------------------------------------
-- Invalid SVI values (should be 0–1)
------------------------------------------------------------
SELECT 
    "FIPS",
    "RPL_THEMES",
    "RPL_THEME1",
    "RPL_THEME2",
    "RPL_THEME3",
    "RPL_THEME4"
FROM svi
WHERE "RPL_THEMES" NOT BETWEEN 0 AND 1
   OR "RPL_THEME1" NOT BETWEEN 0 AND 1
   OR "RPL_THEME2" NOT BETWEEN 0 AND 1
   OR "RPL_THEME3" NOT BETWEEN 0 AND 1
   OR "RPL_THEME4" NOT BETWEEN 0 AND 1;

------------------------------------------------------------
-- Missing CHR or SVI rows for counties in geography
------------------------------------------------------------
SELECT g.fips_st_cnty,
       chr.fips AS chr_fips,
       svi."FIPS" AS svi_fips
FROM dim_geography g
LEFT JOIN population_health_and_well_being_cleaned chr
    ON chr.fips::INTEGER = g.fips_st_cnty
LEFT JOIN svi
    ON svi."FIPS"::INTEGER = g.fips_st_cnty
WHERE chr.fips IS NULL
   OR svi."FIPS" IS NULL;

------------------------------------------------------------
-- Extreme outlier detection (sanity checks)
------------------------------------------------------------
SELECT *
FROM (
    SELECT
        g.fips_st_cnty,
        chr.children_in_poverty / 100.0 AS poverty_pct,
        chr.unemployed_1 / 100.0 AS unemployment_pct,
        chr.income_ratio,
        chr.uninsured_1 / 100.0 AS uninsured_pct,
        chr.households_with_broadband_access_pct / 100.0 AS broadband_pct,
        svi."RPL_THEMES",
        svi."RPL_THEME1",
        svi."RPL_THEME2",
        svi."RPL_THEME3",
        svi."RPL_THEME4"
    FROM dim_geography g
    LEFT JOIN population_health_and_well_being_cleaned chr
        ON chr.fips::INTEGER = g.fips_st_cnty
    LEFT JOIN svi
        ON svi."FIPS"::INTEGER = g.fips_st_cnty
) q
WHERE 
      poverty_pct >= 1000
   OR unemployment_pct >= 1000
   OR income_ratio >= 1000
   OR uninsured_pct >= 1000
   OR broadband_pct >= 1000
   OR broadband_pct < 0
   OR "RPL_THEMES" NOT BETWEEN 0 AND 1
   OR "RPL_THEME1" NOT BETWEEN 0 AND 1
   OR "RPL_THEME2" NOT BETWEEN 0 AND 1
   OR "RPL_THEME3" NOT BETWEEN 0 AND 1
   OR "RPL_THEME4" NOT BETWEEN 0 AND 1;
