CREATE TABLE dim_geography (
    fips_st_cnty INTEGER NOT NULL,
    population_year INTEGER NOT NULL,
    state_name VARCHAR(50),
    state_abbr VARCHAR(5),
    county_name VARCHAR(100),
    region VARCHAR(50),
    division VARCHAR(50),
    population INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (fips_st_cnty, population_year)
);
