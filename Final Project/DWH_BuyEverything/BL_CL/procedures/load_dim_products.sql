CREATE TYPE bl_cl.t_product_row AS (
    product_src_id           VARCHAR,
    product_subcategory_id   BIGINT,
    product_subcategory_name VARCHAR,
    product_category_id      BIGINT,
    product_category_name    VARCHAR
);

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    v_row      bl_cl.t_product_row;
BEGIN
    FOR v_row IN
        SELECT
            p.product_id::VARCHAR                           AS product_src_id,
            COALESCE(sub.product_subcategory_id, -1)        AS product_subcategory_id,
            COALESCE(sub.product_subcategory_name, 'n. a.') AS product_subcategory_name,
            COALESCE(cat.product_category_id, -1)           AS product_category_id,
            COALESCE(cat.product_category_name, 'n. a.')    AS product_category_name
        FROM bl_3nf.ce_products p
        LEFT JOIN bl_3nf.ce_subcategories sub ON sub.product_subcategory_id = p.product_subcategory_id
        LEFT JOIN bl_3nf.ce_categories   cat ON cat.product_category_id     = sub.product_category_id
        WHERE p.product_id <> -1
    LOOP
        -- UPDATE if attributes changed
        UPDATE bl_dm.dim_products tgt
        SET product_subcategory_id   = v_row.product_subcategory_id,
            product_subcategory_name = v_row.product_subcategory_name,
            product_category_id      = v_row.product_category_id,
            product_category_name    = v_row.product_category_name,
            update_dt = CURRENT_DATE
        WHERE tgt.product_src_id = v_row.product_src_id
          AND tgt.source_system  = 'BL_3NF'
          AND (tgt.product_subcategory_name IS DISTINCT FROM v_row.product_subcategory_name
            OR tgt.product_category_name    IS DISTINCT FROM v_row.product_category_name);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        -- INSERT if new (one row per 3NF product)
        INSERT INTO bl_dm.dim_products (
            product_surr_id, product_subcategory_id, product_subcategory_name,
            product_category_id, product_category_name, source_system,
            source_entity, product_src_id, insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_products_surr_id'),
               v_row.product_subcategory_id, v_row.product_subcategory_name,
               v_row.product_category_id, v_row.product_category_name,
               'BL_3NF', 'CE_PRODUCTS', v_row.product_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products tgt
            WHERE tgt.product_src_id = v_row.product_src_id
              AND tgt.source_system  = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_dim_products', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (composite type)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_products', 'ERROR', NULL, SQLERRM);
END;
$$;
