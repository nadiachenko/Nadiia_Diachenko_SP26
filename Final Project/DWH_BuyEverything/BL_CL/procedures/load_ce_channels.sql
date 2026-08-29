CREATE OR REPLACE PROCEDURE bl_cl.load_ce_channels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
    rec        RECORD;
BEGIN
    FOR rec IN
        SELECT DISTINCT
            COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
            COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id,
            'SA_INT_SALES' AS source_system, 'SRC_INT_SALES' AS source_entity
        FROM sa_int_sales.src_int_sales WHERE channel IS NOT NULL
        UNION
        SELECT DISTINCT
            COALESCE(NULLIF(channel, ''), 'n. a.'),
            COALESCE(NULLIF(channel, ''), 'n. a.'),
            'SA_US_SALES', 'SRC_US_SALES'
        FROM sa_us_sales.src_us_sales WHERE channel IS NOT NULL
    LOOP
        UPDATE bl_3nf.ce_channels tgt
        SET channel = rec.channel_name, update_dt = CURRENT_DATE
        WHERE tgt.channel_src_id = rec.channel_src_id
          AND tgt.source_system = rec.source_system
          AND tgt.channel IS DISTINCT FROM rec.channel_name;
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

        INSERT INTO bl_3nf.ce_channels (channel_id, channel, source_system,
            source_entity, channel_src_id, insert_dt, update_dt)
        SELECT nextval('bl_3nf.seq_channels_id'), rec.channel_name,
               rec.source_system, rec.source_entity, rec.channel_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_channels tgt
            WHERE tgt.channel_src_id = rec.channel_src_id
              AND tgt.source_system = rec.source_system);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_ce_channels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_channels', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
