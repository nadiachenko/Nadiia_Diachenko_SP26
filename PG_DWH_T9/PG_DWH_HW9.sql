--  3NF FACT: CE_ORDERS

CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_orders_id START WITH 100 INCREMENT BY 1;


CREATE TABLE IF NOT EXISTS bl_3nf.ce_orders (
    order_id              BIGINT NOT NULL,
    order_dt              DATE NOT NULL,
    order_status          VARCHAR NOT NULL,
    returned              VARCHAR NOT NULL,
    customer_id           BIGINT NOT NULL,
    sales_rep_id          BIGINT NOT NULL,
    product_id            BIGINT NOT NULL,
    subchannel_id         BIGINT NOT NULL,
    city_id               BIGINT NOT NULL,
    payment_method        VARCHAR NOT NULL,
    unit_price            NUMERIC(10,2) NOT NULL,
    quantity              BIGINT NOT NULL,
    discount_percent      BIGINT NOT NULL,
    discount_amount       NUMERIC(10,2) NOT NULL,
    shipping_cost         NUMERIC(10,2) NOT NULL,
    tax_amount            NUMERIC(10,2) NOT NULL,
    order_amount          NUMERIC(10,2) NOT NULL,
    cost_amount           NUMERIC(10,2) NOT NULL,
    profit_margin_percent NUMERIC(10,2) NOT NULL,
    profit_amount         NUMERIC(10,2) NOT NULL,
    transaction_id        VARCHAR NOT NULL,
    source_system         VARCHAR NOT NULL,
    source_entity         VARCHAR NOT NULL,
    order_src_id          VARCHAR NOT NULL,
    insert_dt             DATE NOT NULL,
    update_dt             DATE NOT NULL,
    CONSTRAINT pk_ce_orders PRIMARY KEY (order_id),
    CONSTRAINT uq_ce_orders_bk UNIQUE (order_src_id, source_system),
    CONSTRAINT fk_ce_orders_employee   FOREIGN KEY (sales_rep_id)  REFERENCES bl_3nf.ce_employees(sales_rep_id),
    CONSTRAINT fk_ce_orders_product    FOREIGN KEY (product_id)    REFERENCES bl_3nf.ce_products(product_id),
    CONSTRAINT fk_ce_orders_subchannel FOREIGN KEY (subchannel_id) REFERENCES bl_3nf.ce_subchannels(subchannel_id),
    CONSTRAINT fk_ce_orders_city       FOREIGN KEY (city_id)       REFERENCES bl_3nf.ce_cities(city_id)
);

-- Index supporting the incremental watermark scan
CREATE INDEX IF NOT EXISTS idx_ce_orders_update_dt ON bl_3nf.ce_orders (update_dt);
CREATE INDEX IF NOT EXISTS idx_ce_orders_order_dt  ON bl_3nf.ce_orders (order_dt);


-- INCREMENTAL LOAD of CE_ORDERS

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

-- TEST 
CALL bl_cl.load_ce_orders();
SELECT * FROM bl_cl.mta_load_logs WHERE procedure_name='load_ce_orders' ORDER BY log_id DESC;
SELECT * FROM bl_3nf.ce_orders ORDER BY order_id LIMIT 50;



--  DM FACT

-- 2.1 Drop the old non-partitioned fact (empty at this point)
DROP TABLE IF EXISTS bl_dm.fct_orders_dd;

-- 2.2 Recreate as a partitioned table.

CREATE TABLE bl_dm.fct_orders_dd (
    order_surr_id             BIGINT NOT NULL,
    event_dt                  DATE   NOT NULL,
    product_surr_id           BIGINT NOT NULL,
    customer_surr_id          BIGINT NOT NULL,
    sales_rep_surr_id         BIGINT NOT NULL,
    city_surr_id              BIGINT NOT NULL,
    subchannel_surr_id        BIGINT NOT NULL,
    order_status              VARCHAR NOT NULL,
    returned                  VARCHAR NOT NULL,
    payment_method            VARCHAR NOT NULL,
    fct_unit_price            NUMERIC(10,2) NOT NULL,
    fct_quantity              BIGINT NOT NULL,
    fct_discount_percent      BIGINT NOT NULL,
    fct_discount_amount       NUMERIC(10,2) NOT NULL,
    fct_shipping_cost         NUMERIC(10,2) NOT NULL,
    fct_tax_amount            NUMERIC(10,2) NOT NULL,
    fct_order_amount          NUMERIC(10,2) NOT NULL,
    fct_cost_amount           NUMERIC(10,2) NOT NULL,
    fct_profit_margin_percent NUMERIC(10,2) NOT NULL,
    fct_profit_amount         NUMERIC(10,2) NOT NULL,
    fct_net_amount            NUMERIC(10,2) NOT NULL,
    source_system             VARCHAR NOT NULL,
    source_entity             VARCHAR NOT NULL,
    order_src_id              VARCHAR NOT NULL,
    insert_dt                 DATE NOT NULL,
    update_dt                 DATE NOT NULL,
    CONSTRAINT pk_fct_orders_dd PRIMARY KEY (order_src_id, source_system, event_dt)
) PARTITION BY RANGE (event_dt);


CREATE TABLE IF NOT EXISTS bl_dm.fct_orders_dd_default PARTITION OF bl_dm.fct_orders_dd DEFAULT;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO dwh_user;


--  DM FACT LOAD 

CREATE OR REPLACE PROCEDURE bl_cl.load_fct_orders_dd(
    p_month_start DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows      INT = 0;
    v_month_end DATE = (p_month_start + INTERVAL '1 month')::DATE;
    v_part      TEXT = 'fct_orders_dd_' || TO_CHAR(p_month_start, 'YYYY_MM');
    v_stage     TEXT = v_part || '_stage';
BEGIN
    IF EXISTS (SELECT 1 FROM pg_inherits i
               JOIN pg_class c ON c.oid = i.inhrelid
               WHERE c.relname = v_part
                 AND i.inhparent = 'bl_dm.fct_orders_dd'::regclass) THEN
        EXECUTE format('ALTER TABLE bl_dm.fct_orders_dd DETACH PARTITION bl_dm.%I', v_part);
        EXECUTE format('DROP TABLE bl_dm.%I', v_part);
    END IF;

    EXECUTE format('DROP TABLE IF EXISTS bl_dm.%I', v_stage);
    EXECUTE format('CREATE TABLE bl_dm.%I (LIKE bl_dm.fct_orders_dd INCLUDING DEFAULTS)', v_stage);

    EXECUTE format($f$
        INSERT INTO bl_dm.%I (
            order_surr_id, event_dt, product_surr_id, customer_surr_id,
            sales_rep_surr_id, city_surr_id, subchannel_surr_id,
            order_status, returned, payment_method,
            fct_unit_price, fct_quantity, fct_discount_percent, fct_discount_amount,
            fct_shipping_cost, fct_tax_amount, fct_order_amount, fct_cost_amount,
            fct_profit_margin_percent, fct_profit_amount, fct_net_amount,
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
            (o.order_amount - o.discount_amount - o.shipping_cost - o.tax_amount),
            'BL_3NF', 'CE_ORDERS', o.order_src_id, CURRENT_DATE, CURRENT_DATE
        FROM bl_3nf.ce_orders o
        LEFT JOIN bl_dm.dim_products      dp  ON dp.product_src_id      = o.product_id::VARCHAR
        LEFT JOIN bl_dm.dim_customers_scd dc  ON dc.customer_src_id     = o.customer_id::VARCHAR
                                             AND dc.source_system       = 'BL_3NF'
                                             AND o.order_dt >= dc.start_dt 
                                             AND o.order_dt <= dc.end_dt
        LEFT JOIN bl_dm.dim_employees     de  ON de.sales_rep_src_id    = o.sales_rep_id::VARCHAR
        LEFT JOIN bl_dm.dim_locations     dl  ON dl.city_name_src_id    = o.city_id::VARCHAR
        LEFT JOIN bl_dm.dim_channels      dch ON dch.subchannel_src_id  = o.subchannel_id::VARCHAR
        WHERE o.order_dt >= %L AND o.order_dt < %L
    $f$, v_stage, p_month_start, v_month_end);

    GET DIAGNOSTICS v_rows = ROW_COUNT;

    EXECUTE format('ALTER TABLE bl_dm.%I RENAME TO %I', v_stage, v_part);
    EXECUTE format($f$
        ALTER TABLE bl_dm.fct_orders_dd
        ATTACH PARTITION bl_dm.%I FOR VALUES FROM (%L) TO (%L)
    $f$, v_part, p_month_start, v_month_end);

    CALL bl_cl.p_log('load_fct_orders_dd', 'SUCCESS', v_rows,
                     'Partition ' || v_part || ' attached with ' || v_rows || ' rows');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_fct_orders_dd', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;


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

-- drop partitions outside the rolling window

CREATE OR REPLACE PROCEDURE bl_cl.prune_fct_partitions(p_keep_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff DATE = DATE_TRUNC('month', CURRENT_DATE - (p_keep_months || ' month')::INTERVAL)::DATE;
    v_dropped INT = 0;
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT c.relname AS part_name
        FROM pg_inherits i
        JOIN pg_class c ON c.oid = i.inhrelid
        WHERE i.inhparent = 'bl_dm.fct_orders_dd'::regclass
          AND c.relname ~ '^fct_orders_dd_\d{4}_\d{2}$'
          AND TO_DATE(RIGHT(c.relname, 7), 'YYYY_MM') < v_cutoff
    LOOP
        EXECUTE format('ALTER TABLE bl_dm.fct_orders_dd DETACH PARTITION bl_dm.%I', rec.part_name);
        EXECUTE format('DROP TABLE bl_dm.%I', rec.part_name);
        v_dropped = v_dropped + 1;
    END LOOP;

    CALL bl_cl.p_log('prune_fct_partitions', 'SUCCESS', v_dropped,
                     'Detached/dropped ' || v_dropped || ' partitions older than ' || v_cutoff);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('prune_fct_partitions', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

call bl_cl.load_fct_auto(6)

