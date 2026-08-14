CREATE OR REPLACE PROCEDURE bl_cl.load_ce_subchannels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_subchannels tgt
    SET subchannel = src.subchannel_name, channel_id = ch.channel_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_int_sales.src_int_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_INT_SALES'
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.subchannel IS DISTINCT FROM src.subchannel_name
        OR tgt.channel_id IS DISTINCT FROM ch.channel_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system,
        source_entity, subchannel_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subchannels_id'), src.subchannel_name, ch.channel_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.subchannel_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_int_sales.src_int_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subchannels tgt
        WHERE tgt.subchannel_src_id = src.subchannel_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_subchannels tgt
    SET subchannel = src.subchannel_name, channel_id = ch.channel_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_us_sales.src_us_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_US_SALES'
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.subchannel IS DISTINCT FROM src.subchannel_name
        OR tgt.channel_id IS DISTINCT FROM ch.channel_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system,
        source_entity, subchannel_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subchannels_id'), src.subchannel_name, ch.channel_id,
           'SA_US_SALES', 'SRC_US_SALES', src.subchannel_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_us_sales.src_us_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subchannels tgt
        WHERE tgt.subchannel_src_id = src.subchannel_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

   CALL bl_cl.p_log('load_ce_subchannels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_subchannels', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
