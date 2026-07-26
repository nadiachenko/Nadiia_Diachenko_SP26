CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_locations_surr_id START WITH 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_locations (
    city_surr_id BIGINT NOT NULL,
    city_name VARCHAR NOT NULL,
    state_id BIGINT NOT NULL,
    state VARCHAR NOT NULL,
    country_id BIGINT NOT NULL,
    country_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    city_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_locations PRIMARY KEY (city_surr_id)
);

-- default (-1) row
INSERT INTO bl_dm.dim_locations (
    city_surr_id, city_name_src_id, city_name, state_id, state, 
    country_id, country_name, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, -1, 'n. a.', -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_locations WHERE city_surr_id = -1);

ALTER TABLE bl_dm.dim_locations
ADD CONSTRAINT uq_dim_locations_bk UNIQUE (city_name_src_id, source_system);
