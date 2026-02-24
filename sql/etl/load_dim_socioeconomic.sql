-- ETL: Load dim_socioeconomic
-- Purpose:
--   • Populate socioeconomic indicators for 2023 using CHR and SVI datasets
--   • Convert CHR percentages from whole-number format to decimal fractions
--   • Join SVI 2022 county-level vulnerability metrics
--   • Ensure every county in dim_geography receives a socioeconomic profile
-- Notes:
--   • CHR fields (poverty, unemployment, uninsured, broadband) are stored as whole-number percentages
--     and must be divided by 100 to convert to decimal format
--   • SVI values are already in 0–1 decimal format
-- Version: 1.0

INSERT INTO dim_socioeconomic (
    fips_st_cnty,
    year,
    poverty_pct,
    unemployment_pct,
    income_ratio,
    uninsured_pct,
    broadband_access_pct,
    svi_overall_rank,
    svi_socioeconomic_theme,
    svi_household_theme,
    svi_minority_theme,
    svi_housing_theme,
    created_at,
    updated_at
)
SELECT
    g.fips_st_cnty,
    2023 AS year,

    -- Convert whole-number percentages to decimals
    ROUND(CAST(chr.children_in_poverty / 100.0 AS NUMERIC), 6) AS poverty_pct,
    ROUND(CAST(chr.unemployed_1 / 100.0 AS NUMERIC), 6) AS unemployment_pct,
    ROUND(CAST(chr.income_ratio AS NUMERIC), 6) AS income_ratio,
    ROUND(CAST(chr.uninsured_1 / 100.0 AS NUMERIC), 6) AS uninsured_pct,

    -- Broadband access percentage → decimal
    ROUND(CAST(chr.households_with_broadband_access_pct / 100.0 AS NUMERIC), 6) AS broadband_access_pct,

    -- SVI values already in decimal format
    ROUND(CAST(svi."RPL_THEMES" AS NUMERIC), 6) AS svi_overall_rank,
    ROUND(CAST(svi."RPL_THEME1" AS NUMERIC), 6) AS svi_socioeconomic_theme,
    ROUND(CAST(svi."RPL_THEME2" AS NUMERIC), 6) AS svi_household_theme,
    ROUND(CAST(svi."RPL_THEME3" AS NUMERIC), 6) AS svi_minority_theme,
    ROUND(CAST(svi."RPL_THEME4" AS NUMERIC), 6) AS svi_housing_theme,

    NOW(),
    NOW()
FROM dim_geography g
LEFT JOIN population_health_and_well_being_cleaned chr
    ON chr.fips::INTEGER = g.fips_st_cnty
LEFT JOIN svi
    ON svi."FIPS"::INTEGER = g.fips_st_cnty;
