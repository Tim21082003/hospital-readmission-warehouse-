CREATE TABLE fact_county_health_outcomes (
    fact_id                         BIGSERIAL PRIMARY KEY,
    fips_st_cnty                    INTEGER NOT NULL,
    year                            INTEGER NOT NULL,

    -- Core readmission & utilization metrics
    acute_hosp_readmsn_cnt          INTEGER,
    acute_hosp_readmsn_pct          NUMERIC(6,3),
    er_visits_per_1000_benes        NUMERIC(10,2),
    ip_cvrd_stays_per_1000_benes    NUMERIC(10,2),

    -- Medicare cost metrics
    tot_mdcr_stdzd_pymt_pc          NUMERIC(12,2),
    ip_mdcr_stdzd_pymt_pc           NUMERIC(12,2),
    snf_mdcr_stdzd_pymt_pc          NUMERIC(12,2),
    hh_mdcr_stdzd_pymt_pc           NUMERIC(12,2),

    -- Preventable admissions (PQI)
    pqi_chf_75plus                  INTEGER,
    pqi_copd_75plus                 INTEGER,
    pqi_diabetes_75plus             INTEGER,
    pqi_hypertension_75plus         INTEGER,
    pqi_pneumonia_75plus            INTEGER,
    pqi_uti_75plus                  INTEGER,

    -- Aggregated hospital performance (weighted)
    total_readmissions              INTEGER,
    avg_excess_readmission_ratio    NUMERIC(6,3),
    avg_predicted_readmission_rate  NUMERIC(6,3),
    avg_expected_readmission_rate   NUMERIC(6,3),

    -- SDOH indicators (from CHR, SVI, PLACES)
    poverty_pct                     NUMERIC(5,2),
    uninsured_pct                   NUMERIC(5,2),
    unemployment_pct                NUMERIC(5,2),
    income_ratio                    NUMERIC(6,3),
    broadband_access_pct            NUMERIC(5,2),
    svi_overall_rank                NUMERIC(6,3),

    -- Behavioral health indicators (PLACES)
    smoking_pct                     NUMERIC(5,2),
    obesity_pct                     NUMERIC(5,2),
    diabetes_pct                    NUMERIC(5,2),
    poor_mental_health_pct          NUMERIC(5,2),

    -- Provider access (AHRF)
    primary_care_physicians_rate    NUMERIC(10,2),
    mental_health_provider_rate     NUMERIC(10,2),
    dentist_rate                    NUMERIC(10,2),
    hospital_beds_per_1000          NUMERIC(10,2),

    created_at                      TIMESTAMP DEFAULT NOW(),
    updated_at                      TIMESTAMP DEFAULT NOW(),

    FOREIGN KEY (fips_st_cnty)
        REFERENCES dim_geography (fips_st_cnty)
);
