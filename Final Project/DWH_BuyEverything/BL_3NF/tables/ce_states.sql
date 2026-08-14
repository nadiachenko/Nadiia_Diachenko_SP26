CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_states_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_states (
    state_id BIGINT NOT NULL,
    state_name VARCHAR NOT NULL,
    country_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    state_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_states PRIMARY KEY (state_id),
    CONSTRAINT fk_ce_states_country FOREIGN KEY (country_id) 
        REFERENCES bl_3nf.ce_countries(country_id)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system, source_entity, state_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (state_id) DO NOTHING;
