CREATE OR REPLACE PROCEDURE bl_cl.load_dim_locations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_aff INT = 0;
BEGIN
    INSERT INTO bl_dm.dim_locations (
        city_surr_id, city_name, state_id, state, country_id, country_name,
        source_system, source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT
        nextval('bl_dm.seq_dim_locations_surr_id'),
        ci.city_name, st.state_id, st.state_name, cn.country_id, cn.country_name,
        'BL_3NF', 'CE_CITIES', ci.city_id::VARCHAR,
        CURRENT_DATE, CURRENT_DATE
    FROM bl_3nf.ce_cities ci
    JOIN bl_3nf.ce_states    st ON st.state_id   = ci.state_id
    JOIN bl_3nf.ce_countries cn ON cn.country_id = st.country_id
    WHERE ci.city_id <> -1
    ON CONFLICT (city_name_src_id, source_system) DO UPDATE
        SET city_name    = EXCLUDED.city_name,
            state_id     = EXCLUDED.state_id,
            state        = EXCLUDED.state,
            country_id   = EXCLUDED.country_id,
            country_name = EXCLUDED.country_name,
            update_dt    = CURRENT_DATE
        WHERE dim_locations.city_name    IS DISTINCT FROM EXCLUDED.city_name
           OR dim_locations.state        IS DISTINCT FROM EXCLUDED.state
           OR dim_locations.country_name IS DISTINCT FROM EXCLUDED.country_name;
           
    GET DIAGNOSTICS v_rows_aff = ROW_COUNT;

    -- 1. Log SUCCESS (4 parameters, p_sqlstate defaults to NULL)
    CALL bl_cl.p_log('load_dim_locations', 'SUCCESS', v_rows_aff,
                     'Rows affected: ' || v_rows_aff || ' (upsert ON CONFLICT)');

EXCEPTION WHEN OTHERS THEN
    -- 2. Log ERROR with 5 parameters (including SQLSTATE) and propagate exception
    CALL bl_cl.p_log('load_dim_locations', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;