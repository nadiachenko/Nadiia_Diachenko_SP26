CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_countries_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_countries (
    country_id BIGINT NOT NULL,
    country_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    country_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_countries PRIMARY KEY (country_id)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_countries (country_id, country_name, source_system, source_entity, country_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (country_id) DO NOTHING;
