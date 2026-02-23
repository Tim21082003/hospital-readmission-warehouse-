-- ETL: ZIP Code Normalization
-- Purpose:
--   • Standardize ZIP codes in dim_hospital
--   • Remove ZIP+4 extensions
--   • Pad ZIPs to 5 digits
-- Notes:
--   • Ensures consistent matching with ZIP-to-FIPS crosswalk
--   • Should be run before county assignment ETL
-- Version: 1.0

UPDATE dim_hospital
SET zip_code = LPAD(SPLIT_PART(zip_code, '-', 1), 5, '0')
WHERE zip_code IS NOT NULL;
