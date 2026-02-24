-- ETL: Correct and backfill PQI fields in fact_county_health_outcomes
-- Purpose:
--   • Update missing or incomplete PQI metrics using deduped Medicare PUF data
--   • Apply regex validation and MAX() aggregation to ensure clean county-level values
--   • Refresh only PQI fields without altering other fact table metrics
-- Notes:
--   • Required because the initial fact load did not fully populate PQI fields
--   • Must be run after fact_county_health_outcomes is loaded for 2023
-- Version: 1.0

UPDATE fact_county_health_outcomes f
SET 
    pqi_chf_75plus = m.pqi_chf_75plus,
    pqi_copd_75plus = m.pqi_copd_75plus,
    pqi_diabetes_75plus = m.pqi_diabetes_75plus,
    pqi_hypertension_75plus = m.pqi_hypertension_75plus,
    pqi_pneumonia_75plus = m.pqi_pneumonia_75plus,
    pqi_uti_75plus = m.pqi_uti_75plus,
    updated_at = NOW()
FROM (
    SELECT
        m."BENE_GEO_CD"::INTEGER AS fips,   
        MAX(CASE WHEN m."PQI08_CHF_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI08_CHF_AGE_GE_75"::NUMERIC END)
            AS pqi_chf_75plus,
        MAX(CASE WHEN m."PQI05_COPD_ASTHMA_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI05_COPD_ASTHMA_AGE_GE_75"::NUMERIC END)
            AS pqi_copd_75plus,
        MAX(CASE WHEN m."PQI03_DBTS_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI03_DBTS_AGE_GE_75"::NUMERIC END)
            AS pqi_diabetes_75plus,
        MAX(CASE WHEN m."PQI07_HYPRTNSN_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI07_HYPRTNSN_AGE_GE_75"::NUMERIC END)
            AS pqi_hypertension_75plus,
        MAX(CASE WHEN m."PQI11_BCTRL_PNA_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI11_BCTRL_PNA_AGE_GE_75"::NUMERIC END)
            AS pqi_pneumonia_75plus,
        MAX(CASE WHEN m."PQI12_UTI_AGE_GE_75" ~ '^[0-9.]+$'
                 THEN m."PQI12_UTI_AGE_GE_75"::NUMERIC END)
            AS pqi_uti_75plus
    FROM "2014_medicare_fee" m
    WHERE m."BENE_GEO_LVL" = 'County'
      AND m."YEAR" = 2023
    GROUP BY m."BENE_GEO_CD"
) m
WHERE f.fips_st_cnty = m.fips
  AND f.year = 2023;
