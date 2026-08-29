CREATE OR REPLACE PROCEDURE bl_cl.load_ce_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins  INT = 0;
    v_rows_upd  INT = 0;
    v_tmp       INT = 0;
    v_watermark TIMESTAMP;
BEGIN
    SELECT COALESCE(MAX(log_dt), TIMESTAMP '1900-01-01')
    INTO v_watermark
    FROM bl_cl.mta_load_logs
    WHERE procedure_name = 'load_ce_orders' AND log_status = 'SUCCESS';

    -- INT source 
    WITH incoming AS (
        SELECT
            COALESCE(NULLIF(o.order_id_int, ''), 'n. a.')                     AS order_src_id,
            CAST(COALESCE(NULLIF(o.order_dt_int, ''), '1900-01-01') AS DATE)  AS order_dt,
            COALESCE(NULLIF(o.order_status_int, ''), 'n. a.')                 AS order_status,
            COALESCE(NULLIF(o.returned, ''), 'n. a.')                         AS returned,
            COALESCE(NULLIF(o.customer_id_int, ''), 'n. a.')                  AS customer_src_id,
            COALESCE(NULLIF(o.sales_rep_id_int, ''), 'n. a.')                 AS rep_src_id,
            COALESCE(NULLIF(o.product_id_int, ''), 'n. a.')                   AS product_src_id,
            COALESCE(NULLIF(o.subchannel, ''), 'n. a.')                       AS subchannel_src_id,
            COALESCE(NULLIF(o.city_int, ''), 'n. a.')                         AS city_src_id,
            COALESCE(NULLIF(o.payment, ''), 'n. a.')                          AS payment_method,
            CAST(COALESCE(NULLIF(o.price, ''), '0') AS NUMERIC(10,2))         AS unit_price,
            CAST(COALESCE(NULLIF(o.quantity_int, ''), '0') AS BIGINT)         AS quantity,
            CAST(COALESCE(NULLIF(o.discount_percent_int, ''), '0') AS BIGINT) AS discount_percent,
            CAST(COALESCE(NULLIF(o.discount_amount_int, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
            CAST(COALESCE(NULLIF(o.shipping_cost_int, ''), '0') AS NUMERIC(10,2))   AS shipping_cost,
            CAST(COALESCE(NULLIF(o.tax, ''), '0') AS NUMERIC(10,2))                 AS tax_amount,
            CAST(COALESCE(NULLIF(o.order_amount_int, ''), '0') AS NUMERIC(10,2))    AS order_amount,
            CAST(COALESCE(NULLIF(o.cost_amount_int, ''), '0') AS NUMERIC(10,2))     AS cost_amount,
            CAST(COALESCE(NULLIF(o.pprofit_margin_percent_int, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
            CAST(COALESCE(NULLIF(o.profit_amount_int, ''), '0') AS NUMERIC(10,2))   AS profit_amount
        FROM sa_int_sales.src_int_sales o
        WHERE o.order_id_int IS NOT NULL
          AND o.insert_date > v_watermark 
    ),
    mapped AS (
        SELECT s.*,
               COALESCE(c.customer_id,   -1) AS customer_id,
               COALESCE(e.sales_rep_id,  -1) AS sales_rep_id,
               COALESCE(p.product_id,    -1) AS product_id,
               COALESCE(sc.subchannel_id,-1) AS subchannel_id,
               COALESCE(ci.city_id,      -1) AS city_id
        FROM incoming s
        LEFT JOIN bl_3nf.ce_customers_scd c
               ON c.customer_src_id = s.customer_src_id
              AND c.source_system   = 'SA_INT_SALES'
              AND s.order_dt BETWEEN c.start_dt AND c.end_dt
        LEFT JOIN bl_3nf.ce_employees e
               ON e.sales_rep_src_id = s.rep_src_id     AND e.source_system = 'SA_INT_SALES'
        LEFT JOIN bl_3nf.ce_products p
               ON p.product_src_id   = s.product_src_id AND p.source_system = 'SA_INT_SALES'
        LEFT JOIN bl_3nf.ce_subchannels sc
               ON sc.subchannel_src_id = s.subchannel_src_id AND sc.source_system = 'SA_INT_SALES'
        LEFT JOIN bl_3nf.ce_cities ci
               ON ci.city_name_src_id = s.city_src_id   AND ci.source_system = 'SA_INT_SALES'
    )
    INSERT INTO bl_3nf.ce_orders (
        order_id, order_dt, order_status, returned, customer_id, sales_rep_id,
        product_id, subchannel_id, city_id, payment_method, unit_price, quantity,
        discount_percent, discount_amount, shipping_cost, tax_amount, order_amount,
        cost_amount, profit_margin_percent, profit_amount, transaction_id,
        source_system, source_entity, order_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_orders_id'),
           m.order_dt, m.order_status, m.returned, m.customer_id, m.sales_rep_id,
           m.product_id, m.subchannel_id, m.city_id, m.payment_method, m.unit_price,
           m.quantity, m.discount_percent, m.discount_amount, m.shipping_cost,
           m.tax_amount, m.order_amount, m.cost_amount, m.profit_margin_percent,
           m.profit_amount, m.order_src_id,
           'SA_INT_SALES', 'SRC_INT_SALES', m.order_src_id, CURRENT_DATE, CURRENT_DATE
    FROM mapped m
    ON CONFLICT (order_src_id, source_system) DO UPDATE           
        SET order_status  = EXCLUDED.order_status,
            returned      = EXCLUDED.returned,
            order_amount  = EXCLUDED.order_amount,
            profit_amount = EXCLUDED.profit_amount,
            update_dt     = CURRENT_DATE
        WHERE ce_orders.order_status  IS DISTINCT FROM EXCLUDED.order_status
           OR ce_orders.returned      IS DISTINCT FROM EXCLUDED.returned
           OR ce_orders.order_amount  IS DISTINCT FROM EXCLUDED.order_amount
           OR ce_orders.profit_amount IS DISTINCT FROM EXCLUDED.profit_amount;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;

    --US source
    WITH incoming AS (
        SELECT
            COALESCE(NULLIF(o.order_id, ''), 'n. a.')                        AS order_src_id,
            CAST(COALESCE(NULLIF(o.order_dt, ''), '1900-01-01') AS DATE)     AS order_dt,
            COALESCE(NULLIF(o.order_status, ''), 'n. a.')                    AS order_status,
            COALESCE(NULLIF(o.returned, ''), 'n. a.')                        AS returned,
            COALESCE(NULLIF(o.customer_id, ''), 'n. a.')                     AS customer_src_id,
            COALESCE(NULLIF(o.sales_rep_id, ''), 'n. a.')                    AS rep_src_id,
            COALESCE(NULLIF(o.product_id, ''), 'n. a.')                      AS product_src_id,
            COALESCE(NULLIF(o.subchannel, ''), 'n. a.')                      AS subchannel_src_id,
            COALESCE(NULLIF(o.city, ''), 'n. a.')                            AS city_src_id,
            COALESCE(NULLIF(o.state, ''), 'n. a.')                           AS state_src_id,
            COALESCE(NULLIF(o.payment_method, ''), 'n. a.')                  AS payment_method,
            CAST(COALESCE(NULLIF(o.unit_price, ''), '0') AS NUMERIC(10,2))   AS unit_price,
            CAST(COALESCE(NULLIF(o.quantity, ''), '0') AS BIGINT)            AS quantity,
            CAST(COALESCE(NULLIF(o.discount_percent, ''), '0') AS BIGINT)    AS discount_percent,
            CAST(COALESCE(NULLIF(o.discount_amount, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
            CAST(COALESCE(NULLIF(o.shipping_cost, ''), '0') AS NUMERIC(10,2))   AS shipping_cost,
            CAST(COALESCE(NULLIF(o.tax_amount, ''), '0') AS NUMERIC(10,2))      AS tax_amount,
            CAST(COALESCE(NULLIF(o.order_amount, ''), '0') AS NUMERIC(10,2))    AS order_amount,
            CAST(COALESCE(NULLIF(o.cost_amount, ''), '0') AS NUMERIC(10,2))     AS cost_amount,
            CAST(COALESCE(NULLIF(o.profit_margin_percent, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
            CAST(COALESCE(NULLIF(o.profit_margin_amount, ''), '0') AS NUMERIC(10,2))  AS profit_amount
        FROM sa_us_sales.src_us_sales o
        WHERE o.order_id IS NOT NULL
          AND o.insert_date > v_watermark          
    ),
    mapped AS (
        SELECT s.*,
               COALESCE(c.customer_id,   -1) AS customer_id,
               COALESCE(e.sales_rep_id,  -1) AS sales_rep_id,
               COALESCE(p.product_id,    -1) AS product_id,
               COALESCE(sc.subchannel_id,-1) AS subchannel_id,
               COALESCE(ci.city_id,      -1) AS city_id
        FROM incoming s
        LEFT JOIN bl_3nf.ce_customers_scd c
               ON c.customer_src_id = s.customer_src_id
              AND c.source_system   = 'SA_US_SALES'
              AND s.order_dt BETWEEN c.start_dt AND c.end_dt
        LEFT JOIN bl_3nf.ce_employees e
               ON e.sales_rep_src_id = s.rep_src_id     AND e.source_system = 'SA_US_SALES'
        LEFT JOIN bl_3nf.ce_products p
               ON p.product_src_id   = s.product_src_id AND p.source_system = 'SA_US_SALES'
        LEFT JOIN bl_3nf.ce_subchannels sc
               ON sc.subchannel_src_id = s.subchannel_src_id AND sc.source_system = 'SA_US_SALES'
        -- US cities are disambiguated by state (same city name in several states)
        LEFT JOIN bl_3nf.ce_states st
               ON st.state_name_src_id = s.state_src_id AND st.source_system = 'SA_US_SALES'
        LEFT JOIN bl_3nf.ce_cities ci
               ON ci.city_name_src_id = s.city_src_id
              AND ci.source_system    = 'SA_US_SALES'
              AND ci.state_id         = st.state_id
    )
    INSERT INTO bl_3nf.ce_orders (
        order_id, order_dt, order_status, returned, customer_id, sales_rep_id,
        product_id, subchannel_id, city_id, payment_method, unit_price, quantity,
        discount_percent, discount_amount, shipping_cost, tax_amount, order_amount,
        cost_amount, profit_margin_percent, profit_amount, transaction_id,
        source_system, source_entity, order_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_orders_id'),
           m.order_dt, m.order_status, m.returned, m.customer_id, m.sales_rep_id,
           m.product_id, m.subchannel_id, m.city_id, m.payment_method, m.unit_price,
           m.quantity, m.discount_percent, m.discount_amount, m.shipping_cost,
           m.tax_amount, m.order_amount, m.cost_amount, m.profit_margin_percent,
           m.profit_amount, m.order_src_id,
           'SA_US_SALES', 'SRC_US_SALES', m.order_src_id, CURRENT_DATE, CURRENT_DATE
    FROM mapped m
    ON CONFLICT (order_src_id, source_system) DO UPDATE
        SET order_status  = EXCLUDED.order_status,
            returned      = EXCLUDED.returned,
            order_amount  = EXCLUDED.order_amount,
            profit_amount = EXCLUDED.profit_amount,
            update_dt     = CURRENT_DATE
        WHERE ce_orders.order_status  IS DISTINCT FROM EXCLUDED.order_status
           OR ce_orders.returned      IS DISTINCT FROM EXCLUDED.returned
           OR ce_orders.order_amount  IS DISTINCT FROM EXCLUDED.order_amount
           OR ce_orders.profit_amount IS DISTINCT FROM EXCLUDED.profit_amount;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_orders', 'SUCCESS', v_rows_ins,
                     'Rows affected: ' || v_rows_ins ||
                     ' (incremental since ' || v_watermark || ')');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_orders', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;
