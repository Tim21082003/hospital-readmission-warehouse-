CREATE TABLE dim_hospital (
    facility_id                 VARCHAR(20) PRIMARY KEY,
    facility_name               VARCHAR(255),
    address                     VARCHAR(255),
    city                        VARCHAR(100),
    state                       VARCHAR(5),
    zip_code                    VARCHAR(10),
    fips_st_cnty                INTEGER,
    hospital_type               VARCHAR(100),
    hospital_ownership          VARCHAR(100),
    emergency_services          BOOLEAN,
    overall_star_rating         NUMERIC(3,1),
    readm_measure_count         INTEGER,
    readm_measures_better       INTEGER,
    readm_measures_no_diff      INTEGER,
    readm_measures_worse        INTEGER,
    created_at                  TIMESTAMP DEFAULT NOW(),
    updated_at                  TIMESTAMP DEFAULT NOW(),
    CONSTRAINT fk_hospital_geography
        FOREIGN KEY (fips_st_cnty)
        REFERENCES dim_geography (fips_st_cnty)
);
