CREATE TABLE dim_socioeconomic (
    socio_id                    BIGSERIAL PRIMARY KEY,
    fips_st_cnty                INTEGER NOT NULL,
    year                        INTEGER NOT NULL,

    -- Core socioeconomic indicators (CHR, SVI, AHRF)
    poverty_pct                 NUMERIC(5,2),
    unemployment_pct            NUMERIC(5,2),
    income_ratio                NUMERIC(6,3),
    uninsured_pct               NUMERIC(5,2),
    broadband_access_pct        NUMERIC(5,2),

    -- Social Vulnerability Index (SVI)
    svi_overall_rank            NUMERIC(6,3),
    svi_socioeconomic_theme     NUMERIC(6,3),
    svi_household_theme         NUMERIC(6,3),
    svi_minority_theme          NUMERIC(6,3),
    svi_housing_theme           NUMERIC(6,3),

    created_at                  TIMESTAMP DEFAULT NOW(),
    updated_at                  TIMESTAMP DEFAULT NOW(),

    FOREIGN KEY (fips_st_cnty)
        REFERENCES dim_geography (fips_st_cnty)
);
