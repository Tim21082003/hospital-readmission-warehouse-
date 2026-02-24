-- ETL: Load dim_date
-- Purpose:
--   • Populate the date dimension with a full calendar from 2010–2030
--   • Generate surrogate date_id in YYYYMMDD format
--   • Add standard date attributes (year, quarter, month, weekday, weekend flag)
-- Notes:
--   • This is a synthetic dimension (no source tables required)
--   • Should be run once when initializing the warehouse
-- Version: 1.0

WITH RECURSIVE dates AS (
    SELECT DATE '2010-01-01' AS full_date
    UNION ALL
    SELECT (full_date + INTERVAL '1 day')::DATE
    FROM dates
    WHERE full_date < DATE '2030-12-31'
)
INSERT INTO dim_date (
    date_id,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_name,
    day_of_week,
    is_weekend,
    created_at,
    updated_at
)
SELECT
    EXTRACT(YEAR FROM full_date)::INT * 10000 +
    EXTRACT(MONTH FROM full_date)::INT * 100 +
    EXTRACT(DAY FROM full_date)::INT AS date_id,
    full_date,
    EXTRACT(YEAR FROM full_date)::INT AS year,
    EXTRACT(QUARTER FROM full_date)::INT AS quarter,
    EXTRACT(MONTH FROM full_date)::INT AS month,
    TO_CHAR(full_date, 'Month') AS month_name,
    EXTRACT(DAY FROM full_date)::INT AS day,
    TO_CHAR(full_date, 'Day') AS day_name,
    EXTRACT(DOW FROM full_date)::INT AS day_of_week,
    CASE WHEN EXTRACT(DOW FROM full_date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend,
    NOW(),
    NOW()
FROM dates
ORDER BY full_date;
