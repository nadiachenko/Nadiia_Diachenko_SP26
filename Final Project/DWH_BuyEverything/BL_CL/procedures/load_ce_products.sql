CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_products tgt
    SET product_subcategory_id = sub.product_subcategory_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
              COALESCE(NULLIF(subcategory, ''), 'n. a.')    AS subcategory_name
          FROM sa_int_sales.src_int_sales WHERE product_id_int IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_INT_SALES'
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system,
        source_entity, product_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_products_id'), sub.product_subcategory_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.product_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
              COALESCE(NULLIF(subcategory, ''), 'n. a.')    AS subcategory_name
          FROM sa_int_sales.src_int_sales WHERE product_id_int IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products tgt
        WHERE tgt.product_src_id = src.product_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_products tgt
    SET product_subcategory_id = sub.product_subcategory_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
          FROM sa_us_sales.src_us_sales WHERE product_id IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_US_SALES'
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system,
        source_entity, product_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_products_id'), sub.product_subcategory_id,
           'SA_US_SALES', 'SRC_US_SALES', src.product_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
          FROM sa_us_sales.src_us_sales WHERE product_id IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products tgt
        WHERE tgt.product_src_id = src.product_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_products', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_products', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
$$;
