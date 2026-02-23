CREATE TABLE dim_health_behaviors (
    behavior_id                 BIGSERIAL PRIMARY KEY,
    fips_st_cnty                INTEGER NOT NULL,
    year                        INTEGER NOT NULL,

    -- Core PLACES behavioral risk factors
    smoking_pct                 NUMERIC(5,2),
    obesity_pct                 NUMERIC(5,2),
    diabetes_pct                NUMERIC(5,2),
    poor_mental_health_pct      NUMERIC(5,2),

    -- Additional PLACES indicators (optional but useful)
    no_routine_checkup_pct      NUMERIC(5,2),
    physical_inactivity_pct     NUMERIC(5,2),
    binge_drinking_pct          NUMERIC(5,2),

    created_at                  TIMESTAMP DEFAULT NOW(),
    updated_at                  TIMESTAMP DEFAULT NOW(),

    FOREIGN KEY (fips_st_cnty)
        REFERENCES dim_geography (fips_st_cnty)
);
