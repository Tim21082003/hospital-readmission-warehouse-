-- ETL: Load fact_county_health_outcomes
-- Purpose:
--   • Integrate Medicare Geographic Variation PUF, HRRP hospital readmissions,
--     County Health Rankings, and Provider Access data into a unified county-level fact table
--   • Deduplicate Medicare data at the county level
--   • Aggregate hospital-level readmission metrics to counties
--   • Join SDOH, utilization, and provider supply indicators
-- Notes:
--   • Loads 2023 county-level outcomes
--   • Requires dim_geography, dim_provider_access, and fact_hospital_readmissions to be populated
-- Version: 1.0

WITH medicare_dedup AS (
    SELECT
        m."BENE_GEO_CD"::INTEGER AS fips,

        MAX(CASE WHEN m."ACUTE_HOSP_READMSN_CNT" ~ '^[0-9]+$'
                 THEN m."ACUTE_HOSP_READMSN_CNT"::INTEGER END)
            AS acute_hosp_readmsn_cnt,

        MAX(CASE WHEN m."ACUTE_HOSP_READMSN_PCT" ~ '^[0-9.]+$'
                 THEN m."ACUTE_HOSP_READMSN_PCT"::NUMERIC END)
            AS acute_hosp_readmsn_pct,

        MAX(CASE WHEN m."ER_VISITS_PER_1000_BENES" ~ '^[0-9.]+$'
                 THEN m."ER_VISITS_PER_1000_BENES"::NUMERIC END)
            AS er_visits_per_1000_benes,

        MAX(CASE WHEN m."IP_CVRD_STAYS_PER_1000_BENES" ~ '^[0-9.]+$'
                 THEN m."IP_CVRD_STAYS_PER_1000_BENES"::NUMERIC END)
            AS ip_cvrd_stays_per_1000_benes,

        MAX(CASE WHEN m."TOT_MDCR_STDZD_PYMT_PC" ~ '^[0-9.]+$'
                 THEN m."TOT_MDCR_STDZD_PYMT_PC"::NUMERIC END)
            AS tot_mdcr_stdzd_pymt_pc,

        MAX(CASE WHEN m."IP_MDCR_STDZD_PYMT_PC" ~ '^[0-9.]+$'
                 THEN m."IP_MDCR_STDZD_PYMT_PC"::NUMERIC END)
            AS ip_mdcr_stdzd_pymt_pc,

        MAX(CASE WHEN m."SNF_MDCR_STDZD_PYMT_PC" ~ '^[0-9.]+$'
                 THEN m."SNF_MDCR_STDZD_PYMT_PC"::NUMERIC END)
            AS snf_mdcr_stdzd_pymt_pc,

        MAX(CASE WHEN m."HH_MDCR_STDZD_PYMT_PC" ~ '^[0-9.]+$'
                 THEN m."HH_MDCR_STDZD_PYMT_PC"::NUMERIC END)
            AS hh_mdcr_stdzd_pymt_pc,

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
),
hrrp AS (
    SELECT
        dh.fips_st_cnty,
        SUM(f.number_of_readmissions) AS total_readmissions,
        AVG(f.excess_readmission_ratio) AS avg_excess_readmission_ratio,
        AVG(f.predicted_readmission_rate) AS avg_predicted_readmission_rate,
        AVG(f.expected_readmission_rate) AS avg_expected_readmission_rate
    FROM fact_hospital_readmissions f
    JOIN dim_hospital dh
      ON f.facility_id = dh.facility_id
    WHERE f.year = 2023
    GROUP BY dh.fips_st_cnty
)
INSERT INTO fact_county_health_outcomes (
    fips_st_cnty,
    year,
    acute_hosp_readmsn_cnt,
    acute_hosp_readmsn_pct,
    er_visits_per_1000_benes,
    ip_cvrd_stays_per_1000_benes,
    tot_mdcr_stdzd_pymt_pc,
    ip_mdcr_stdzd_pymt_pc,
    snf_mdcr_stdzd_pymt_pc,
    hh_mdcr_stdzd_pymt_pc,
    pqi_chf_75plus,
    pqi_copd_75plus,
    pqi_diabetes_75plus,
    pqi_hypertension_75plus,
    pqi_pneumonia_75plus,
    pqi_uti_75plus,
    total_readmissions,
    avg_excess_readmission_ratio,
    avg_predicted_readmission_rate,
    avg_expected_readmission_rate,
    created_at,
    updated_at
)
SELECT
    g.fips_st_cnty,
    2023,
    m.acute_hosp_readmsn_cnt,
    m.acute_hosp_readmsn_pct,
    m.er_visits_per_1000_benes,
    m.ip_cvrd_stays_per_1000_benes,
    m.tot_mdcr_stdzd_pymt_pc,
    m.ip_mdcr_stdzd_pymt_pc,
    m.snf_mdcr_stdzd_pymt_pc,
    m.hh_mdcr_stdzd_pymt_pc,
    m.pqi_chf_75plus,
    m.pqi_copd_75plus,
    m.pqi_diabetes_75plus,
    m.pqi_hypertension_75plus,
    m.pqi_pneumonia_75plus,
    m.pqi_uti_75plus,
    h.total_readmissions,
    h.avg_excess_readmission_ratio,
    h.avg_predicted_readmission_rate,
    h.avg_expected_readmission_rate,
    NOW(),
    NOW()
FROM dim_geography g
LEFT JOIN medicare_dedup m
    ON m.fips = g.fips_st_cnty
LEFT JOIN population_health_and_well_being_cleaned chr
    ON chr.fips::INTEGER = g.fips_st_cnty
LEFT JOIN dim_provider_access p
    ON p.fips_st_cnty = g.fips_st_cnty
   AND p.year = 2023
LEFT JOIN hrrp h
    ON h.fips_st_cnty = g.fips_st_cnty;
