-- ETL: Load fact_hospital_readmissions
-- Purpose:
--   • Transform and load CMS HRRP data into the hospital readmissions fact table
--   • Join cleaned HRRP staging data to dim_hospital to retrieve surrogate keys
--   • Ensure numeric fields are validated and typed before loading
-- Notes:
--   • This script depends on dim_hospital being fully populated
--   • fips_st_cnty is inherited from dim_hospital
-- Version: 1.0

WITH hrrp_base AS (
    SELECT
        "Facility ID"::TEXT AS facility_id,
        "Measure Name"::TEXT AS measure_name,
        CASE WHEN "Excess Readmission Ratio" ~ '^[0-9\.\-]+$'
             THEN "Excess Readmission Ratio"::NUMERIC(12,6)
             ELSE NULL END AS excess_readmission_ratio,
        CASE WHEN "Predicted Readmission Rate" ~ '^[0-9\.\-]+$'
             THEN "Predicted Readmission Rate"::NUMERIC(12,6)
             ELSE NULL END AS predicted_readmission_rate,
        CASE WHEN "Expected Readmission Rate" ~ '^[0-9\.\-]+$'
             THEN "Expected Readmission Rate"::NUMERIC(12,6)
             ELSE NULL END AS expected_readmission_rate,
        CASE WHEN "Number of Readmissions" ~ '^[0-9]+$'
             THEN "Number of Readmissions"::INTEGER
             ELSE NULL END AS number_of_readmissions,
        CASE WHEN "Number of Discharges" ~ '^[0-9]+$'
             THEN "Number of Discharges"::INTEGER
             ELSE NULL END AS number_of_discharges,
        2023 AS year
    FROM fy_hospital_readmissions
),
joined AS (
    SELECT
        hb.*,
        dh.hospital_key,
        dh.fips_st_cnty
    FROM hrrp_base hb
    JOIN dim_hospital dh
        ON dh.facility_id = hb.facility_id
)
INSERT INTO fact_hospital_readmissions (
    facility_id,
    year,
    measure_name,
    excess_readmission_ratio,
    predicted_readmission_rate,
    expected_readmission_rate,
    number_of_readmissions,
    fips_st_cnty,
    hospital_key,
    created_at,
    updated_at
)
SELECT
    facility_id,
    year,
    measure_name,
    excess_readmission_ratio,
    predicted_readmission_rate,
    expected_readmission_rate,
    number_of_readmissions,
    fips_st_cnty,
    hospital_key,
    NOW(),
    NOW()
FROM joined;
