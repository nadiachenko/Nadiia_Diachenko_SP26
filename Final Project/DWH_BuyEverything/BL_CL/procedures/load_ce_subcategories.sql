CREATE OR REPLACE PROCEDURE bl_cl.load_ce_subcategories()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_subcategories tgt
    SET product_subcategory_name = src.subcategory_name,
        product_category_id = cat.product_category_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_int_sales.src_int_sales WHERE subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_INT_SALES'
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
        OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name,
        product_category_id, source_system, source_entity, product_subcategory_name_src_id,
        insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subcategories_id'), src.subcategory_name, cat.product_category_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.subcategory_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_int_sales.src_int_sales WHERE subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subcategories tgt
        WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_subcategories tgt
    SET product_subcategory_name = src.subcategory_name,
        product_category_id = cat.product_category_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_us_sales.src_us_sales WHERE product_subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_US_SALES'
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
        OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name,
        product_category_id, source_system, source_entity, product_subcategory_name_src_id,
        insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subcategories_id'), src.subcategory_name, cat.product_category_id,
           'SA_US_SALES', 'SRC_US_SALES', src.subcategory_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_us_sales.src_us_sales WHERE product_subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subcategories tgt
        WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_subcategories', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_subcategories', 'ERROR', NULL, SQLERRM);
END;
$$;
