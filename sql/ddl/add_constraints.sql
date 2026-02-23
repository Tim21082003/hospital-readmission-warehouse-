ALTER TABLE fact_county_health_outcomes
    ADD CONSTRAINT fk_fact_socio
        FOREIGN KEY (socio_id)
        REFERENCES dim_socioeconomic (socio_id);

ALTER TABLE fact_county_health_outcomes
    ADD CONSTRAINT fk_fact_behavior
        FOREIGN KEY (behavior_id)
        REFERENCES dim_health_behaviors (behavior_id);

ALTER TABLE fact_county_health_outcomes
    ADD CONSTRAINT fk_fact_access
        FOREIGN KEY (access_id)
        REFERENCES dim_provider_access (access_id);

ALTER TABLE dim_provider_access 
DROP COLUMN uninsured_pct;

ALTER TABLE fact_county_health_outcomes
ADD COLUMN benes_ffs_cnt INTEGER;
