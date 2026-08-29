CREATE OR REPLACE PROCEDURE bl_cl.load_ce_cities()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_cities tgt
    SET city_name = src.city_name,
        state_id = st.state_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_name,
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_key
          FROM sa_int_sales.src_int_sales WHERE city_int IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_key
       AND st.source_system = 'SA_INT_SALES'
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.city_name IS DISTINCT FROM src.city_name
        OR tgt.state_id IS DISTINCT FROM st.state_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system,
        source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_cities_id'), src.city_name, st.state_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.city_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_name,
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_key
          FROM sa_int_sales.src_int_sales WHERE city_int IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_key
       AND st.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_cities tgt
        WHERE tgt.city_name_src_id = src.city_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_cities tgt
    SET city_name = src.city_name,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_src_id
          FROM sa_us_sales.src_us_sales WHERE city IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_name
       AND st.source_system = 'SA_US_SALES'
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.state_id = st.state_id
      AND (tgt.city_name IS DISTINCT FROM src.city_name);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system,
        source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_cities_id'), src.city_name, st.state_id,
           'SA_US_SALES', 'SRC_US_SALES', src.city_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_src_id
          FROM sa_us_sales.src_us_sales WHERE city IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_name
       AND st.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_cities tgt
        WHERE tgt.city_name_src_id = src.city_src_id
          AND tgt.source_system = 'SA_US_SALES'
          AND tgt.state_id = st.state_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_cities', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_cities', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
