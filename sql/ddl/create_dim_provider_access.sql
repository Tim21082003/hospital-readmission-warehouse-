CREATE TABLE dim_provider_access (
    access_id                       BIGSERIAL PRIMARY KEY,
    fips_st_cnty                    INTEGER NOT NULL,
    population_year                 INTEGER NOT NULL,
    year                            INTEGER NOT NULL,
    primary_care_physicians_rate    NUMERIC(10,2),
    mental_health_provider_rate     NUMERIC(10,2),
    dentist_rate                    NUMERIC(10,2),
    specialist_physicians_rate      NUMERIC(10,2),
    hospital_beds_per_1000          NUMERIC(10,2),
    rn_supply_rate                  NUMERIC(10,2),
    lpn_supply_rate                 NUMERIC(10,2),
    preventable_hospitalization_rate NUMERIC(10,2),
    uninsured_pct                    NUMERIC(5,2),
    created_at                      TIMESTAMP DEFAULT NOW(),
    updated_at                      TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (fips_st_cnty, population_year)
        REFERENCES dim_geography (fips_st_cnty, population_year)
);
