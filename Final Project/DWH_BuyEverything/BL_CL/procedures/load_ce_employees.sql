CREATE OR REPLACE PROCEDURE bl_cl.load_ce_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT
    UPDATE bl_3nf.ce_employees tgt
    SET sales_rep_first_name = src.first_name,
        sales_rep_last_name  = src.last_name,
        sales_rep_email      = src.email,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email_int, ''), 'n. a.')      AS email
          FROM sa_int_sales.src_int_sales WHERE sales_rep_id_int IS NOT NULL) src
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
        OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
        OR tgt.sales_rep_email      IS DISTINCT FROM src.email);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;
 INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name,
        sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_employees_id'), src.first_name, src.last_name, src.email,
           'SA_INT_SALES', 'SRC_INT_SALES', src.rep_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email_int, ''), 'n. a.')      AS email
          FROM sa_int_sales.src_int_sales WHERE sales_rep_id_int IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_employees tgt
        WHERE tgt.sales_rep_src_id = src.rep_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
  -- US
    UPDATE bl_3nf.ce_employees tgt
    SET sales_rep_first_name = src.first_name,
        sales_rep_last_name  = src.last_name,
        sales_rep_email      = src.email,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email, ''), 'n. a.')      AS email
          FROM sa_us_sales.src_us_sales WHERE sales_rep_id IS NOT NULL) src
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
        OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
        OR tgt.sales_rep_email      IS DISTINCT FROM src.email);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name,
        sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_employees_id'), src.first_name, src.last_name, src.email,
           'SA_US_SALES', 'SRC_US_SALES', src.rep_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email, ''), 'n. a.')      AS email
          FROM sa_us_sales.src_us_sales WHERE sales_rep_id IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_employees tgt
        WHERE tgt.sales_rep_src_id = src.rep_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
   CALL bl_cl.p_log('load_ce_employees', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_ce_employees', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
