-- Staging Transform: HRRP Joined to Dimensions
-- Purpose:
--   • Join cleaned HRRP staging data to dim_hospital and dim_geography
--   • Validate surrogate keys (hospital_key, geography_key)
--   • Identify missing joins before fact table load
-- Notes:
--   • This is a preview query (LIMIT 50) used for validation
--   • Final fact load will reference this joined dataset
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
        dh.fips_st_cnty AS hospital_fips,
        dg.geography_key
    FROM hrrp_base hb
    JOIN dim_hospital dh
        ON dh.facility_id = hb.facility_id
    LEFT JOIN dim_geography dg
        ON dg.fips_st_cnty = dh.fips_st_cnty
)
SELECT *
FROM joined
LIMIT 50;
