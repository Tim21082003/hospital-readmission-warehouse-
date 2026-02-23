CREATE TABLE dim_date (
    date_id            INTEGER PRIMARY KEY,   -- YYYYMMDD format
    full_date          DATE NOT NULL,
    year               INTEGER NOT NULL,
    quarter            INTEGER,
    month              INTEGER,
    month_name         VARCHAR(20),
    day                INTEGER,
    day_of_week        INTEGER,
    day_name           VARCHAR(20),
    is_weekend         BOOLEAN,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW()
);
