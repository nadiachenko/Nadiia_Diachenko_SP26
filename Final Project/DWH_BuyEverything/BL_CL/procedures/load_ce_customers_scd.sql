CREATE OR REPLACE PROCEDURE bl_cl.load_ce_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_exp INT := 0;
    v_tmp      INT := 0;
BEGIN
    -- INT 
    UPDATE bl_3nf.ce_customers_scd tgt
    SET is_active = 'N', end_dt = CURRENT_DATE - 1, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(customer_id_int, ''), 'n. a.')         AS customer_src_id,
              COALESCE(NULLIF(customer_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(customer_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(customer_email_int, ''), 'n. a.')      AS email,
              'n. a.' AS age, 'n. a.' AS gender, 'n. a.' AS segment
          FROM sa_int_sales.src_int_sales WHERE customer_id_int IS NOT NULL) src
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.source_system = 'SA_INT_SALES' AND tgt.is_active = 'Y'
      AND (tgt.customer_first_name IS DISTINCT FROM src.first_name
        OR tgt.customer_last_name  IS DISTINCT FROM src.last_name
        OR tgt.customer_email      IS DISTINCT FROM src.email
        OR tgt.customer_age        IS DISTINCT FROM src.age
        OR tgt.customer_gender     IS DISTINCT FROM src.gender
        OR tgt.customer_segment    IS DISTINCT FROM src.segment);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_exp := v_rows_exp + v_tmp;

    INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name,
        customer_email, customer_age, customer_gender, customer_segment, source_system,
        source_entity, customer_src_id, is_active, start_dt, end_dt, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_customers_id'), src.first_name, src.last_name, src.email,
           src.age, src.gender, src.segment, 'SA_INT_SALES', 'SRC_INT_SALES', src.customer_src_id,
           'Y', CURRENT_DATE, DATE '9999-12-31', CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(customer_id_int, ''), 'n. a.')         AS customer_src_id,
              COALESCE(NULLIF(customer_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(customer_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(customer_email_int, ''), 'n. a.')      AS email,
              'n. a.' AS age, 'n. a.' AS gender, 'n. a.' AS segment
          FROM sa_int_sales.src_int_sales WHERE customer_id_int IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_customers_scd tgt
        WHERE tgt.customer_src_id = src.customer_src_id
          AND tgt.source_system = 'SA_INT_SALES' AND tgt.is_active = 'Y');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US 
    UPDATE bl_3nf.ce_customers_scd tgt
    SET is_active = 'N', end_dt = CURRENT_DATE - 1, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(customer_id, ''), 'n. a.')         AS customer_src_id,
              COALESCE(NULLIF(customer_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(customer_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(customer_email, ''), 'n. a.')      AS email,
              COALESCE(NULLIF(customer_age, ''), 'n. a.')        AS age,
              COALESCE(NULLIF(customer_gender, ''), 'n. a.')     AS gender,
              COALESCE(NULLIF(customer_segment, ''), 'n. a.')    AS segment
          FROM sa_us_sales.src_us_sales WHERE customer_id IS NOT NULL) src
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.source_system = 'SA_US_SALES' AND tgt.is_active = 'Y'
      AND (tgt.customer_first_name IS DISTINCT FROM src.first_name
        OR tgt.customer_last_name  IS DISTINCT FROM src.last_name
        OR tgt.customer_email      IS DISTINCT FROM src.email
        OR tgt.customer_age        IS DISTINCT FROM src.age
        OR tgt.customer_gender     IS DISTINCT FROM src.gender
        OR tgt.customer_segment    IS DISTINCT FROM src.segment);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_exp := v_rows_exp + v_tmp;

    INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name,
        customer_email, customer_age, customer_gender, customer_segment, source_system,
        source_entity, customer_src_id, is_active, start_dt, end_dt, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_customers_id'), src.first_name, src.last_name, src.email,
           src.age, src.gender, src.segment, 'SA_US_SALES', 'SRC_US_SALES', src.customer_src_id,
           'Y', CURRENT_DATE, DATE '9999-12-31', CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(customer_id, ''), 'n. a.')         AS customer_src_id,
              COALESCE(NULLIF(customer_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(customer_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(customer_email, ''), 'n. a.')      AS email,
              COALESCE(NULLIF(customer_age, ''), 'n. a.')        AS age,
              COALESCE(NULLIF(customer_gender, ''), 'n. a.')     AS gender,
              COALESCE(NULLIF(customer_segment, ''), 'n. a.')    AS segment
          FROM sa_us_sales.src_us_sales WHERE customer_id IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_customers_scd tgt
        WHERE tgt.customer_src_id = src.customer_src_id
          AND tgt.source_system = 'SA_US_SALES' AND tgt.is_active = 'Y');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_customers_scd', 'SUCCESS', v_rows_ins + v_rows_exp,
                     'Inserted: ' || v_rows_ins || ', Expired: ' || v_rows_exp);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_customers_scd', 'ERROR', NULL, SQLERRM);
END;
$$;
