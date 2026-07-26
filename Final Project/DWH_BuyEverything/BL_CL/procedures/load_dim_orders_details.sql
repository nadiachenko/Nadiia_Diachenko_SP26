CREATE OR REPLACE PROCEDURE bl_cl.load_dim_orders_details()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
    UPDATE bl_dm.dim_orders_details tgt
    SET order_status   = src.order_status,
        returned       = src.returned,
        payment_method = src.payment_method,
        update_dt      = CURRENT_DATE
    FROM (SELECT order_id::VARCHAR AS order_src_id,
                 order_status, returned, payment_method
          FROM bl_3nf.ce_orders
          WHERE order_id <> -1) src
    WHERE tgt.order_src_id  = src.order_src_id
      AND tgt.source_system = 'BL_3NF'
      AND (tgt.order_status   IS DISTINCT FROM src.order_status
        OR tgt.returned       IS DISTINCT FROM src.returned
        OR tgt.payment_method IS DISTINCT FROM src.payment_method);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_dm.dim_orders_details (
        order_surr_id, order_status, returned, payment_method,
        source_system, source_entity, order_src_id, insert_dt, update_dt)
    SELECT nextval('bl_dm.seq_order_details_surr_id'),
           src.order_status, src.returned, src.payment_method,
           'BL_3NF', 'CE_ORDERS', src.order_src_id,
           CURRENT_DATE, CURRENT_DATE
    FROM (SELECT order_id::VARCHAR AS order_src_id,
                 order_status, returned, payment_method
          FROM bl_3nf.ce_orders
          WHERE order_id <> -1) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_orders_details tgt
        WHERE tgt.order_src_id  = src.order_src_id
          AND tgt.source_system = 'BL_3NF');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_dim_orders_details', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_orders_details', 'ERROR', NULL, SQLERRM);
END;
$$;
