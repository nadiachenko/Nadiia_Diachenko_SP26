CREATE SEQUENCE IF NOT EXISTS bl_cl.seq_mta_test_cases_id   START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_cl.mta_test_cases (
    test_id    BIGINT DEFAULT nextval('bl_cl.seq_mta_test_cases_id') NOT NULL,
    test_name  VARCHAR NOT NULL,
    test_group VARCHAR NOT NULL,
    test_type  VARCHAR NOT NULL,
    test_sql   TEXT NOT NULL,
    is_active  BOOLEAN DEFAULT TRUE NOT NULL,
    CONSTRAINT pk_mta_test_cases PRIMARY KEY (test_id),
    CONSTRAINT uq_mta_test_cases_name UNIQUE (test_name),
    CONSTRAINT chk_mta_test_cases_type CHECK (test_type IN ('ASSERT_ZERO','INFO'))
);

-- seed test cases
INSERT INTO bl_cl.mta_test_cases (test_name, test_group, test_type, test_sql) VALUES
('no_dup_ce_orders', 'GROUP 1 - No duplicates', 'ASSERT_ZERO',
 'SELECT COUNT(*) FROM (SELECT order_src_id, source_system FROM bl_3nf.ce_orders GROUP BY 1,2 HAVING COUNT(*) > 1) d'),
('no_dup_fct_orders_dd', 'GROUP 1 - No duplicates', 'ASSERT_ZERO',
 'SELECT COUNT(*) FROM (SELECT order_src_id, source_system FROM bl_dm.fct_orders_dd GROUP BY 1,2 HAVING COUNT(*) > 1) d'),
('completeness_int_orders', 'GROUP 2 - SA fully represented', 'ASSERT_ZERO',
 'SELECT COUNT(*) FROM (SELECT DISTINCT order_id_int FROM sa_int_sales.src_int_sales WHERE order_id_int IS NOT NULL) s WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_orders o WHERE o.order_src_id = s.order_id_int AND o.source_system = ''SA_INT_SALES'')'),
('completeness_us_orders', 'GROUP 2 - SA fully represented', 'ASSERT_ZERO',
 'SELECT COUNT(*) FROM (SELECT DISTINCT order_id FROM sa_us_sales.src_us_sales WHERE order_id IS NOT NULL) s WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_orders o WHERE o.order_src_id = s.order_id AND o.source_system = ''SA_US_SALES'')'),
('completeness_3nf_to_dm', 'GROUP 2 - SA fully represented', 'ASSERT_ZERO',
 'SELECT COUNT(*) FROM bl_3nf.ce_orders o WHERE o.order_dt >= DATE_TRUNC(''month'', (SELECT MAX(order_dt) FROM bl_3nf.ce_orders) - INTERVAL ''2 month'') AND NOT EXISTS (SELECT 1 FROM bl_dm.fct_orders_dd f WHERE f.order_src_id = o.order_src_id)'),
('info_unresolved_dim_keys', 'INFO', 'INFO',
 'SELECT COUNT(*) FROM bl_dm.fct_orders_dd WHERE product_surr_id = -1 OR customer_surr_id = -1 OR sales_rep_surr_id = -1 OR city_surr_id = -1 OR subchannel_surr_id = -1')
ON CONFLICT (test_name) DO NOTHING;
