CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_channels_surr_id START WITH 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_channels (
    subchannel_surr_id BIGINT NOT NULL,
    subchannel VARCHAR NOT NULL,
    channel_id BIGINT NOT NULL,
    channel VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    subchannel_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_channels PRIMARY KEY (subchannel_surr_id)
);

-- default (-1) row
INSERT INTO bl_dm.dim_channels (
    subchannel_surr_id, subchannel_src_id, subchannel, channel_id, channel, 
    source_system, source_entity, insert_dt, update_dt
)
SELECT -1, -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_channels WHERE subchannel_surr_id = -1);
