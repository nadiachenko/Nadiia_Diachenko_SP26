CREATE OR REPLACE PROCEDURE bl_cl.load_dim_channels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    c_channels CURSOR FOR
        SELECT DISTINCT ON (COALESCE(ch.channel, 'n. a.'), sc.subchannel)
            sc.subchannel_id::VARCHAR       AS subchannel_src_id,
            sc.subchannel,
            COALESCE(ch.channel_id, -1)     AS channel_id,
            COALESCE(ch.channel, 'n. a.')   AS channel
        FROM bl_3nf.ce_subchannels sc
        LEFT JOIN bl_3nf.ce_channels ch ON ch.channel_id = sc.channel_id
        WHERE sc.subchannel_id <> -1
        ORDER BY COALESCE(ch.channel, 'n. a.'), sc.subchannel, sc.subchannel_id; 
BEGIN
    FOR rec IN c_channels LOOP
        UPDATE bl_dm.dim_channels tgt
        SET channel_id = rec.channel_id,
            update_dt  = CURRENT_DATE
        WHERE tgt.subchannel = rec.subchannel
          AND tgt.channel    = rec.channel
          AND tgt.source_system = 'BL_3NF'
          AND tgt.channel_id IS DISTINCT FROM rec.channel_id;
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        INSERT INTO bl_dm.dim_channels (
            subchannel_surr_id, subchannel, channel_id, channel,
            source_system, source_entity, subchannel_src_id, insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_channels_surr_id'),
               rec.subchannel, rec.channel_id, rec.channel,
               'BL_3NF', 'CE_SUBCHANNELS', rec.subchannel_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_channels tgt
            WHERE tgt.subchannel = rec.subchannel
              AND tgt.channel    = rec.channel
              AND tgt.source_system = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_dim_channels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (cursor FOR loop, conformed)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_channels', 'ERROR', NULL, SQLERRM);
END;
$$;
