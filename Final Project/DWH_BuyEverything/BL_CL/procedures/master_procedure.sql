CREATE OR REPLACE PROCEDURE bl_cl.load_bl_3nf()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL bl_cl.load_ce_categories();
    CALL bl_cl.load_ce_subcategories();
    CALL bl_cl.load_ce_products();
    CALL bl_cl.load_ce_countries();
    CALL bl_cl.load_ce_states();
    CALL bl_cl.load_ce_cities();
    CALL bl_cl.load_ce_channels();
    CALL bl_cl.load_ce_subchannels();
    CALL bl_cl.load_ce_employees();
    CALL bl_cl.load_ce_customers_scd();
    CALL bl_cl.load_ce_orders();
    CALL bl_cl.p_log('load_bl_3nf', 'SUCCESS', NULL, 'All BL_3NF loads completed');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_bl_3nf', 'ERROR', NULL, SQLERRM);
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_bl_dm(p_window_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL bl_cl.load_dim_products();
    CALL bl_cl.load_dim_channels();
    CALL bl_cl.load_dim_employees();
    CALL bl_cl.load_dim_locations();
    CALL bl_cl.load_dim_orders_details();
    CALL bl_cl.load_dim_customers_scd_incr();
    CALL bl_cl.load_fct_auto(p_window_months);
    CALL bl_cl.p_log('load_bl_dm', 'SUCCESS', NULL, 'All BL_DM loads completed');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_bl_dm', 'ERROR', NULL, SQLERRM);
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.load_all(p_window_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
BEGIN
    CALL bl_cl.load_bl_3nf();
    CALL bl_cl.load_bl_dm(p_window_months);
    CALL bl_cl.p_log('load_all', 'SUCCESS', NULL, 'Full BL_3NF + BL_DM load completed');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_all', 'ERROR', NULL, SQLERRM);
END;
$$;


CALL bl_cl.load_all(3);
CALL bl_cl.run_all_tests();
SELECT * FROM bl_cl.get_load_summary();