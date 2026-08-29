CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_subchannels_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_subchannels (
    subchannel_id BIGINT NOT NULL,
    subchannel VARCHAR NOT NULL,
    channel_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    subchannel_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_subchannels PRIMARY KEY (subchannel_id),
    CONSTRAINT fk_ce_subchannels_chan FOREIGN KEY (channel_id) 
        REFERENCES bl_3nf.ce_channels(channel_id)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system, source_entity, subchannel_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (subchannel_id) DO NOTHING;
