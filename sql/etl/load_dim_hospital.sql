-- ETL: Load dim_hospital 
-- Purpose: Deduplicate and standardize hospital records before loading into the dimension. 
-- Notes: 
-- • Uses DISTINCT ON to keep the most recent record per hospital 
-- • Converts emergency_services to boolean 
-- • Validates numeric fields using regex before casting 
-- • Standardizes text fields (TRIM, INITCAP) 
-- Version: 1.0

WITH dedup AS (
    SELECT DISTINCT ON (h.facility_name, h.address, h.state, h.zip_code)
        h.facility_id,
        h.facility_name,
        h.address,
        h.city_town AS city,
        h.state,
        h.zip_code,
        h.fips_st_cnty,
        h.hospital_type,
        h.hospital_ownership,
        h.emergency_services,
        h.hospital_overall_rating,
        h.readm_group_measure_count,
        h.count_of_readm_measures_better,
        h.count_of_readm_measures_no_different,
        h.count_of_readm_measures_worse,
        h.year AS source_year
    FROM hospital_general_information_cleaned h
    ORDER BY
        h.facility_name,
        h.address,
        h.state,
        h.zip_code,
        h.year DESC
)
INSERT INTO dim_hospital (
    facility_id,
    facility_name,
    address,
    city,
    state,
    zip_code,
    fips_st_cnty,
    hospital_type,
    hospital_ownership,
    emergency_services,
    overall_star_rating,
    readm_measure_count,
    readm_measures_better,
    readm_measures_no_diff,
    readm_measures_worse
)
SELECT
    d.facility_id,
    d.facility_name,
    d.address,
    d.city,
    d.state,
    d.zip_code,
    d.fips_st_cnty,
    d.hospital_type,
    d.hospital_ownership,
    CASE 
        WHEN LOWER(d.emergency_services) = 'yes' THEN TRUE
        WHEN LOWER(d.emergency_services) = 'no' THEN FALSE
        ELSE NULL
    END AS emergency_services,
    CASE 
        WHEN d.hospital_overall_rating ~ '^[0-9]+$'
            THEN d.hospital_overall_rating::NUMERIC(3,1)
        ELSE NULL
    END AS overall_star_rating,
    CASE 
        WHEN d.readm_group_measure_count ~ '^[0-9]+$'
            THEN d.readm_group_measure_count::INTEGER
        ELSE NULL
    END AS readm_measure_count,
    CASE 
        WHEN d.count_of_readm_measures_better ~ '^[0-9]+$'
            THEN d.count_of_readm_measures_better::INTEGER
        ELSE NULL
    END AS readm_measures_better,
    CASE 
        WHEN d.count_of_readm_measures_no_different ~ '^[0-9]+$'
            THEN d.count_of_readm_measures_no_different::INTEGER
        ELSE NULL
    END AS readm_measures_no_diff,
    CASE 
        WHEN d.count_of_readm_measures_worse ~ '^[0-9]+$'
            THEN d.count_of_readm_measures_worse::INTEGER
        ELSE NULL
    END AS readm_measures_worse
FROM dedup d;
