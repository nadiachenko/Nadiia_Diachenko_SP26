CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_exp INT = 0;
    v_tmp      INT = 0;
BEGIN
    -- Expireversions whose attributes changed vs the 3NF row
    UPDATE bl_dm.dim_customers_scd tgt
    SET is_active = 'N',
        end_dt    = CURRENT_DATE - 1,
        update_dt = CURRENT_DATE
    FROM (SELECT customer_id::VARCHAR AS customer_src_id,
                 customer_first_name, customer_last_name, customer_email,
                 customer_age, customer_gender, customer_segment
          FROM bl_3nf.ce_customers_scd
          WHERE is_active = 'Y' AND customer_id <> -1) src
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.source_system   = 'BL_3NF'
      AND tgt.is_active = 'Y'
      AND (tgt.customer_first_name IS DISTINCT FROM src.customer_first_name
        OR tgt.customer_last_name  IS DISTINCT FROM src.customer_last_name
        OR tgt.customer_email      IS DISTINCT FROM src.customer_email
        OR tgt.customer_age        IS DISTINCT FROM src.customer_age
        OR tgt.customer_gender     IS DISTINCT FROM src.customer_gender
        OR tgt.customer_segment    IS DISTINCT FROM src.customer_segment);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_exp = v_rows_exp + v_tmp;

    -- Insert new active version
    INSERT INTO bl_dm.dim_customers_scd (
        customer_surr_id, customer_first_name, customer_last_name, customer_email,
        customer_age, customer_gender, customer_segment, start_dt, end_dt, is_active,
        source_system, source_entity, customer_src_id, insert_dt, update_dt)
    SELECT nextval('bl_dm.seq_dim_customers_surr_id'),
           src.customer_first_name, src.customer_last_name, src.customer_email,
           src.customer_age, src.customer_gender, src.customer_segment,
           CURRENT_DATE, DATE '9999-12-31', 'Y',
           'BL_3NF', 'CE_CUSTOMERS_SCD', src.customer_src_id,
           CURRENT_DATE, CURRENT_DATE
    FROM (SELECT customer_id::VARCHAR AS customer_src_id,
                 customer_first_name, customer_last_name, customer_email,
                 customer_age, customer_gender, customer_segment
          FROM bl_3nf.ce_customers_scd
          WHERE is_active = 'Y' AND customer_id <> -1) src
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_dm.dim_customers_scd tgt
        WHERE tgt.customer_src_id = src.customer_src_id
          AND tgt.source_system   = 'BL_3NF'
          AND tgt.is_active = 'Y');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;

   CALL bl_cl.p_log('load_dim_customers_scd', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Synced: ' || v_rows_upd || ' (SCD2 mirror of 3NF)');

EXCEPTION WHEN OTHERS THEN

    CALL bl_cl.p_log('load_dim_customers_scd', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;
