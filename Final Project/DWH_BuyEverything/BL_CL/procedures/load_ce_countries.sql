CREATE OR REPLACE procedure bl_cl.load_ce_countries()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_aff INT := 0;
BEGIN
    MERGE INTO bl_3nf.ce_countries tgt
    USING (
        SELECT DISTINCT
            COALESCE(NULLIF(country, ''), 'n. a.') AS country_name,
            COALESCE(NULLIF(country, ''), 'n. a.') AS country_src_id,
            'SA_INT_SALES'  AS source_system,
            'SRC_INT_SALES' AS source_entity
        FROM sa_int_sales.src_int_sales
        WHERE country IS NOT NULL
        UNION
        SELECT 'US', 'US', 'SA_US_SALES', 'SRC_US_SALES'
    ) src
    ON  tgt.country_name_src_id = src.country_src_id
    AND tgt.source_system       = src.source_system
    WHEN MATCHED AND tgt.country_name IS DISTINCT FROM src.country_name THEN
        UPDATE SET country_name = src.country_name,
                   update_dt    = CURRENT_DATE
    WHEN NOT MATCHED THEN
        INSERT (country_id, country_name, source_system,
                source_entity, country_name_src_id, insert_dt, update_dt)
        VALUES (nextval('bl_3nf.seq_countries_id'), src.country_name, src.source_system,
                src.source_entity, src.country_src_id, CURRENT_DATE, CURRENT_DATE);
    GET DIAGNOSTICS v_rows_aff = ROW_COUNT;

    CALL bl_cl.p_log('load_ce_countries', 'SUCCESS', v_rows_aff,
                     'Rows affected: ' || v_rows_aff || ' (MERGE)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_countries', 'ERROR', NULL, SQLERRM);
END;
$$;
