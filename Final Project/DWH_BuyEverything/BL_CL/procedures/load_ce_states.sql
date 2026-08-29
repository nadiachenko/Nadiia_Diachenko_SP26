CREATE OR REPLACE PROCEDURE bl_cl.load_ce_states()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_states tgt
    SET state_name = src.state_name,
        country_id = cnt.country_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_name,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.')             AS country_key
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = src.country_key
       AND cnt.source_system = 'SA_INT_SALES'
    WHERE tgt.state_name_src_id = src.state_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.state_name IS DISTINCT FROM src.state_name
        OR tgt.country_id IS DISTINCT FROM cnt.country_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system,
        source_entity, state_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_states_id'), src.state_name, cnt.country_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.state_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_name,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.')             AS country_key
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = src.country_key
       AND cnt.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_states tgt
        WHERE tgt.state_name_src_id = src.state_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_states tgt
    SET state_name = src.state_name,
        country_id = cnt.country_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
          FROM sa_us_sales.src_us_sales WHERE state IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = 'US' AND cnt.source_system = 'SA_US_SALES'
    WHERE tgt.state_name_src_id = src.state_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.state_name IS DISTINCT FROM src.state_name
        OR tgt.country_id IS DISTINCT FROM cnt.country_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system,
        source_entity, state_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_states_id'), src.state_name, cnt.country_id,
           'SA_US_SALES', 'SRC_US_SALES', src.state_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
          FROM sa_us_sales.src_us_sales WHERE state IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = 'US' AND cnt.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_states tgt
        WHERE tgt.state_name_src_id = src.state_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_states', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_states', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
