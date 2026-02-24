-- Staging Transform: HRRP Base Table
-- Purpose:
--   • Clean and type-cast raw CMS HRRP fields
--   • Validate numeric fields using regex before casting
--   • Standardize facility_id and measure_name as TEXT
--   • Produce a clean staging layer for fact_hospital_readmissions
-- Notes:
--   • This is a preview query (LIMIT 50) used for validation
--   • Final fact load will reference this CTE
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
)
SELECT *
FROM hrrp_base
LIMIT 50;
