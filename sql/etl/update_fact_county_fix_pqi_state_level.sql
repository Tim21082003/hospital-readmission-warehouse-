-- ETL: State-level PQI fallback update for fact_county_health_outcomes
-- Purpose:
--   • Backfill missing or unreliable PQI metrics using state-level Medicare PUF data
--   • Convert 'NA' and '0' placeholders to NULL before casting
--   • Apply updates only for matching state FIPS and year
-- Notes:
--   • This is a secondary correction step after county-level PQI updates
--   • Ensures no county is left with NULL PQI values
-- Version: 1.0

WITH pqi_state AS (
    SELECT DISTINCT
        LEFT(m."BENE_GEO_CD"::text, 2) AS state_fips,
        m."YEAR",
        NULLIF(m."PQI08_CHF_AGE_GE_75", 'NA') AS PQI08,
        NULLIF(m."PQI05_COPD_ASTHMA_AGE_GE_75", 'NA') AS PQI05,
        NULLIF(m."PQI03_DBTS_AGE_GE_75", 'NA') AS PQI03,
        NULLIF(m."PQI07_HYPRTNSN_AGE_GE_75", 'NA') AS PQI07,
        NULLIF(m."PQI11_BCTRL_PNA_AGE_GE_75", 'NA') AS PQI11,
        NULLIF(m."PQI12_UTI_AGE_GE_75", 'NA') AS PQI12
    FROM "2014_medicare_fee" m
    WHERE (
        NULLIF(m."PQI08_CHF_AGE_GE_75", '0') IS NOT NULL OR
        NULLIF(m."PQI05_COPD_ASTHMA_AGE_GE_75", '0') IS NOT NULL OR
        NULLIF(m."PQI03_DBTS_AGE_GE_75", '0') IS NOT NULL OR
        NULLIF(m."PQI07_HYPRTNSN_AGE_GE_75", '0') IS NOT NULL OR
        NULLIF(m."PQI11_BCTRL_PNA_AGE_GE_75", '0') IS NOT NULL OR
        NULLIF(m."PQI12_UTI_AGE_GE_75", '0') IS NOT NULL
    )
)
UPDATE fact_county_health_outcomes f
SET
    pqi_chf_75plus          = NULLIF(s.PQI08, '0')::numeric,
    pqi_copd_75plus         = NULLIF(s.PQI05, '0')::numeric,
    pqi_diabetes_75plus     = NULLIF(s.PQI03, '0')::numeric,
    pqi_hypertension_75plus = NULLIF(s.PQI07, '0')::numeric,
    pqi_pneumonia_75plus    = NULLIF(s.PQI11, '0')::numeric,
    pqi_uti_75plus          = NULLIF(s.PQI12, '0')::numeric,
    updated_at              = NOW()
FROM pqi_state s
WHERE LEFT(f.fips_st_cnty::text, 2) = s.state_fips
  AND f.year = s."YEAR";
