CREATE OR REPLACE PROCEDURE bl_cl.load_fct_orders_dd(
    p_month_start DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows      INT  := 0;
    v_month_end DATE := (p_month_start + INTERVAL '1 month')::DATE;
    v_part      TEXT := 'fct_orders_dd_' || TO_CHAR(p_month_start, 'YYYY_MM');
    v_stage     TEXT := v_part || '_stage';
BEGIN
    IF EXISTS (SELECT 1 FROM pg_inherits i
               JOIN pg_class c ON c.oid = i.inhrelid
               WHERE c.relname = v_part
                 AND i.inhparent = 'bl_dm.fct_orders_dd'::regclass) THEN
        EXECUTE format('ALTER TABLE bl_dm.fct_orders_dd DETACH PARTITION bl_dm.%I', v_part);
        EXECUTE format('DROP TABLE bl_dm.%I', v_part);
    END IF;
 
    -- Build the month in a standalone table (same structure as the parent)
    EXECUTE format('DROP TABLE IF EXISTS bl_dm.%I', v_stage);
    EXECUTE format('CREATE TABLE bl_dm.%I (LIKE bl_dm.fct_orders_dd INCLUDING DEFAULTS)', v_stage);
 
    -- Load one month of facts, resolving 3NF ids -> DM surrogate keys
    EXECUTE format($f$
        INSERT INTO bl_dm.%I (
            order_surr_id, event_dt, product_surr_id, customer_surr_id,
            sales_rep_surr_id, city_surr_id, subchannel_surr_id,
            order_status, returned, payment_method,
            fct_unit_price, fct_quantity, fct_discount_percent, fct_discount_amount,
            fct_shipping_cost, fct_tax_amount, fct_order_amount, fct_cost_amount,
            fct_profit_margin_percent, fct_profit_amount, fct_net_amount, transaction_id,
            source_system, source_entity, order_src_id, insert_dt, update_dt)
        SELECT
            o.order_id,
            o.order_dt,
            COALESCE(dp.product_surr_id,   -1),
            COALESCE(dc.customer_surr_id,  -1),
            COALESCE(de.sales_rep_surr_id, -1),
            COALESCE(dl.city_surr_id,      -1),
            COALESCE(dch.subchannel_surr_id, -1),
            o.order_status, o.returned, o.payment_method,
            o.unit_price, o.quantity, o.discount_percent, o.discount_amount,
            o.shipping_cost, o.tax_amount, o.order_amount, o.cost_amount,
            o.profit_margin_percent, o.profit_amount,
            (o.order_amount - o.discount_amount - o.shipping_cost - o.tax_amount), o.transaction_id,
            'BL_3NF', 'CE_ORDERS', o.order_id::VARCHAR, CURRENT_DATE, CURRENT_DATE
        FROM bl_3nf.ce_orders o
        LEFT JOIN bl_dm.dim_products      dp  ON dp.product_src_id      = o.product_id::VARCHAR
        LEFT JOIN bl_dm.dim_customers_scd dc  ON dc.customer_src_id     = o.customer_id::VARCHAR
        LEFT JOIN bl_dm.dim_employees     de  ON de.sales_rep_src_id    = o.sales_rep_id::VARCHAR
        LEFT JOIN bl_dm.dim_locations     dl  ON dl.city_name_src_id    = o.city_id::VARCHAR
        LEFT JOIN bl_dm.dim_channels      dch ON dch.subchannel_src_id  = o.subchannel_id::VARCHAR
        WHERE o.order_dt >= %L AND o.order_dt < %L
    $f$, v_stage, p_month_start, v_month_end);
    GET DIAGNOSTICS v_rows = ROW_COUNT;
 
    -- Rename and ATTACH — this CREATES the partition automatically (no manual DDL)
    EXECUTE format('ALTER TABLE bl_dm.%I RENAME TO %I', v_stage, v_part);
    EXECUTE format($f$
        ALTER TABLE bl_dm.fct_orders_dd
        ATTACH PARTITION bl_dm.%I FOR VALUES FROM (%L) TO (%L)
    $f$, v_part, p_month_start, v_month_end);
 
    CALL bl_cl.p_log('load_fct_orders_dd', 'SUCCESS', v_rows,
                     'Partition ' || v_part || ' auto-created & attached with ' || v_rows || ' rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_fct_orders_dd', 'ERROR', NULL, SQLERRM);
END;
$$;