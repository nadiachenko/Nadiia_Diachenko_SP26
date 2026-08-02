CREATE OR REPLACE PROCEDURE bl_cl.load_fct_auto(p_window_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anchor    DATE;
    v_win_start DATE;
    rec         RECORD;
    v_loaded    INT := 0;
BEGIN
    SELECT DATE_TRUNC('month', MAX(order_dt))::DATE INTO v_anchor
    FROM bl_3nf.ce_orders;
 
    IF v_anchor IS NULL THEN
        CALL bl_cl.p_log('load_fct_auto', 'SUCCESS', 0, 'No orders in ce_orders — nothing to load');
        RETURN;
    END IF;
 
    v_win_start := (v_anchor - ((p_window_months - 1) || ' month')::INTERVAL)::DATE;

    FOR rec IN
        SELECT DISTINCT DATE_TRUNC('month', order_dt)::DATE AS month_start
        FROM bl_3nf.ce_orders
        WHERE order_dt >= v_win_start
        ORDER BY 1
    LOOP
        CALL bl_cl.load_fct_orders_dd(rec.month_start); 
        v_loaded := v_loaded + 1;
    END LOOP;

    CALL bl_cl.prune_fct_partitions(p_window_months);
 
    CALL bl_cl.p_log('load_fct_auto', 'SUCCESS', v_loaded,
                     'Auto rolling-window: loaded ' || v_loaded ||
                     ' month(s) from ' || v_win_start || ', pruned older');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_fct_auto', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;
