-- ETL: Load dim_geography 
-- Purpose: Populate the geography dimension from county-level FIPS data. 
-- Notes: 
-- • Standardizes state and county names 
-- • Converts FIPS codes to INTEGER 
-- • Sets population fields to NULL until population data is loaded 
-- • Removes duplicates using SELECT DISTINCT 
-- Version: 1.0 (updated after initial validation)

INSERT INTO dim_geography (
    fips_st_cnty,
    state_fips,
    county_fips,
    state,
    county_name,
    population_year,
    population
)
SELECT DISTINCT
    fips_st_cnty,
    "STATEFP"::INTEGER AS state_fips,
    "COUNTYFP"::INTEGER AS county_fips,
    UPPER(TRIM("STATE")) AS state,
    INITCAP(TRIM("COUNTYNAME")) AS county_name,
    null::INTEGER AS population_year,
    null::INTEGER AS population
FROM fips_codes_for_counties;
