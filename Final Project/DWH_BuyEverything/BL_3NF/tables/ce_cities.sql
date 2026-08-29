CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_cities_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_cities (
    city_id BIGINT NOT NULL,
    city_name VARCHAR NOT NULL,
    state_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    city_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_cities PRIMARY KEY (city_id),
    CONSTRAINT fk_ce_cities_state FOREIGN KEY (state_id) 
        REFERENCES bl_3nf.ce_states(state_id)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system, source_entity, city_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (city_id) DO NOTHING;
