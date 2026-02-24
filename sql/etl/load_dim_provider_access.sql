-- ETL: Load dim_provider_access
-- Purpose:
--   • Populate provider access metrics for 2023 using AHRF 2025 cleaned dataset
--   • Load provider supply, hospital beds, and preventable hospitalization rates
--   • Ensure only valid counties (existing in dim_geography) are loaded
--   • Prevent duplicate loads for the same county-year
-- Notes:
--   • uninsured_pct is set to NULL because 2023 data is unavailable
--   • This script loads one row per county for 2023
-- Version: 1.0

INSERT INTO dim_provider_access (
    fips_st_cnty,
    year,
    population,
    primary_care_physicians_rate,
    mental_health_provider_rate,
    dentist_rate,
    specialist_physicians_rate,
    hospital_beds_per_1000,
    rn_supply_rate,
    lpn_supply_rate,
    preventable_hospitalization_rate,
    created_at,
    updated_at
)
SELECT
    a.fips_st_cnty,
    2023 AS year,
    a.popn_est_23 AS population,
    a.phys_nf_prim_care_pc_exc_rsdt_23 AS primary_care_physicians_rate,
    a.nhsc_fte_mentl_hlth_provdr_23 AS mental_health_provider_rate,
    a.dent_npi_23 AS dentist_rate,
    a.md_nf_all_med_spec_all_pc_23 AS specialist_physicians_rate,
    a.hosp_beds_23 AS hospital_beds_per_1000,
    a.stgh_rn_ft_incl_nh_23 AS rn_supply_rate,
    a.stgh_lpnlvn_ft_incl_nh_23 AS lpn_supply_rate,
    a.medcr_ffs_prev_hosp_rate_22 AS preventable_hospitalization_rate,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ahrf2025_cleaned a
WHERE a.popn_est_23 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM dim_geography g
        WHERE g.fips_st_cnty = a.fips_st_cnty
    )
  AND NOT EXISTS (
        SELECT 1
        FROM dim_provider_access p
        WHERE p.fips_st_cnty = a.fips_st_cnty
          AND p.year = 2023
    );
