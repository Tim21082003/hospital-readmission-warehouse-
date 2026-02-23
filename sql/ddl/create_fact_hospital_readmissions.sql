CREATE TABLE fact_hospital_readmissions (
    fact_id                        BIGSERIAL PRIMARY KEY,
    facility_id                    VARCHAR(20) NOT NULL,
    year                           INTEGER NOT NULL,
    measure_name                   VARCHAR(200) NOT NULL,
    excess_readmission_ratio       NUMERIC(6,3),
    predicted_readmission_rate     NUMERIC(6,3),
    expected_readmission_rate      NUMERIC(6,3),
    number_of_readmissions         INTEGER,
    fips_st_cnty                   INTEGER,
    created_at                     TIMESTAMP DEFAULT NOW(),
    updated_at                     TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_fact_hospital
        FOREIGN KEY (facility_id)
        REFERENCES dim_hospital (facility_id),

    CONSTRAINT fk_fact_hospital_geography
        FOREIGN KEY (fips_st_cnty)
        REFERENCES dim_geography (fips_st_cnty)
);
