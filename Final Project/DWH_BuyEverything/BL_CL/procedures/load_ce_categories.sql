CREATE OR REPLACE PROCEDURE bl_cl.load_ce_categories()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_categories tgt
    SET product_category_name = src.category_name, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
          FROM sa_int_sales.src_int_sales WHERE category IS NOT NULL) src
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.product_category_name IS DISTINCT FROM src.category_name;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name,
        source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_categories_id'), src.category_name,
           'SA_INT_SALES', 'SRC_INT_SALES', src.category_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
          FROM sa_int_sales.src_int_sales WHERE category IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_categories tgt
        WHERE tgt.product_category_name_src_id = src.category_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_categories tgt
    SET product_category_name = src.category_name, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
          FROM sa_us_sales.src_us_sales WHERE product_category IS NOT NULL) src
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.product_category_name IS DISTINCT FROM src.category_name;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name,
        source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_categories_id'), src.category_name,
           'SA_US_SALES', 'SRC_US_SALES', src.category_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
          FROM sa_us_sales.src_us_sales WHERE product_category IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_categories tgt
        WHERE tgt.product_category_name_src_id = src.category_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

CALL bl_cl.p_log('load_ce_categories', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_categories', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;


