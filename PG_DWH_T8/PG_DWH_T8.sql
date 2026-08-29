
--ROLE AND PRIVILEGES
GRANT USAGE ON SCHEMA bl_dm TO dwh_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_dm TO dwh_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_dm TO dwh_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_dm
    GRANT SELECT, INSERT, UPDATE ON TABLES TO dwh_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_dm
    GRANT USAGE, SELECT ON SEQUENCES TO dwh_user;



--  LOGGING (will be reused from Task 7)
CREATE SEQUENCE IF NOT EXISTS bl_cl.seq_mta_load_logs_id START WITH 1 INCREMENT BY 1;

-- log table creation

CREATE TABLE IF NOT exists bl_cl.mta_load_logs (
    log_id         BIGINT DEFAULT nextval('bl_cl.seq_mta_load_logs_id') NOT NULL,
    log_dt         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    procedure_name VARCHAR NOT NULL,
    log_status     VARCHAR NOT NULL,
    rows_affected  INT,
    log_sqlstate   VARCHAR(5),
    log_message    TEXT,
    CONSTRAINT pk_mta_load_logs PRIMARY KEY (log_id),
    CONSTRAINT chk_mta_load_logs_status CHECK (log_status IN ('SUCCESS','ERROR'))
);
-- procedure to log outcome of tables insert/update data

CREATE OR REPLACE PROCEDURE bl_cl.p_log(
    p_procedure_name VARCHAR,
    p_log_status     VARCHAR,
    p_rows_affected  INT,
    p_log_message    TEXT,
    p_sqlstate       VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bl_cl.mta_load_logs (procedure_name, log_status, rows_affected, log_sqlstate, log_message)
    VALUES (p_procedure_name, p_log_status, p_rows_affected, p_sqlstate, p_log_message);
END;
$$;

-- return table type function to display log table

CREATE OR REPLACE FUNCTION bl_cl.get_load_summary()
RETURNS TABLE (
    log_id         BIGINT,
    log_dt         TIMESTAMP,
    procedure_name VARCHAR,
    log_status     VARCHAR,
    rows_affected  INT,
    log_sqlstate   VARCHAR(5),
    log_message    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.log_dt, l.procedure_name, l.log_status, 
           l.rows_affected, l.log_sqlstate, l.log_message
    FROM bl_cl.mta_load_logs l
    ORDER BY l.log_id DESC;
END;
$$;

SELECT * FROM bl_cl.get_load_summary();


-- LOAD PROCEDURES 

-- DIM_PRODUCTS - COMPOSITE TYPE
-- ce_products - ce_subcategories - ce_categories

CREATE TYPE bl_cl.t_product_row AS (
    product_src_id           VARCHAR,
    product_subcategory_id   BIGINT,
    product_subcategory_name VARCHAR,
    product_category_id      BIGINT,
    product_category_name    VARCHAR
);

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    v_row      bl_cl.t_product_row;
BEGIN
    FOR v_row IN
        SELECT
            p.product_id::VARCHAR       AS product_src_id, 
            sub.product_subcategory_id,
            sub.product_subcategory_name,
            cat.product_category_id,
            cat.product_category_name
        FROM bl_3nf.ce_products p
        JOIN bl_3nf.ce_subcategories sub ON sub.product_subcategory_id = p.product_subcategory_id
        JOIN bl_3nf.ce_categories   cat ON cat.product_category_id     = sub.product_category_id
        WHERE p.product_id <> -1
    LOOP
        -- UPDATE if attributes changed
        UPDATE bl_dm.dim_products tgt
        SET product_subcategory_id   = v_row.product_subcategory_id,
            product_subcategory_name = v_row.product_subcategory_name,
            product_category_id      = v_row.product_category_id,
            product_category_name    = v_row.product_category_name,
            update_dt = CURRENT_DATE
        WHERE tgt.product_src_id = v_row.product_src_id
          AND tgt.source_system  = 'BL_3NF'
          AND (tgt.product_subcategory_name IS DISTINCT FROM v_row.product_subcategory_name
            OR tgt.product_category_name    IS DISTINCT FROM v_row.product_category_name);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        -- INSERT if new (one row per 3NF product)
        INSERT INTO bl_dm.dim_products (
            product_surr_id, product_subcategory_id, product_subcategory_name,
            product_category_id, product_category_name, source_system,
            source_entity, product_src_id, insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_products_surr_id'),
               v_row.product_subcategory_id, v_row.product_subcategory_name,
               v_row.product_category_id, v_row.product_category_name,
               'BL_3NF', 'CE_PRODUCTS', v_row.product_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products tgt
            WHERE tgt.product_src_id = v_row.product_src_id
              AND tgt.source_system  = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_dim_products', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (composite type)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_products', 'ERROR', NULL, SQLERRM);
END;
$$;

CALL bl_cl.load_dim_products();
SELECT * FROM bl_cl.mta_load_logs WHERE procedure_name = 'load_dim_products' ORDER BY log_id DESC;
SELECT * FROM bl_dm.dim_products;


-- DIM_CHANNELS (CURSOR FOR LOOP)
-- ce_subchannels - ce_channels

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_channels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    c_channels CURSOR FOR
        SELECT DISTINCT ON (ch.channel, sc.subchannel)
            sc.subchannel_id::VARCHAR AS subchannel_src_id, 
            sc.subchannel,
            ch.channel_id,
            ch.channel
        FROM bl_3nf.ce_subchannels sc
        JOIN bl_3nf.ce_channels ch ON ch.channel_id = sc.channel_id
        WHERE sc.subchannel_id <> -1
        ORDER BY ch.channel, sc.subchannel, sc.subchannel_id; 
BEGIN
    FOR rec IN c_channels LOOP
        UPDATE bl_dm.dim_channels tgt
        SET channel_id = rec.channel_id,
            update_dt  = CURRENT_DATE
        WHERE tgt.subchannel = rec.subchannel
          AND tgt.channel    = rec.channel
          AND tgt.source_system = 'BL_3NF'
          AND tgt.channel_id IS DISTINCT FROM rec.channel_id;
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        INSERT INTO bl_dm.dim_channels (
            subchannel_surr_id, subchannel, channel_id, channel,
            source_system, source_entity, subchannel_src_id, insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_channels_surr_id'),
               rec.subchannel, rec.channel_id, rec.channel,
               'BL_3NF', 'CE_SUBCHANNELS', rec.subchannel_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_channels tgt
            WHERE tgt.subchannel = rec.subchannel
              AND tgt.channel    = rec.channel
              AND tgt.source_system = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_dim_channels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (cursor FOR loop, conformed)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_channels', 'ERROR', NULL, SQLERRM);
END;
$$;


--DIM_EMPLOYEES CURSOR VARIABLES (refcursor)


CREATE OR REPLACE PROCEDURE bl_cl.load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    v_cur      refcursor;   
    v_src_id   VARCHAR;
    v_fname    VARCHAR;
    v_lname    VARCHAR;
    v_email    VARCHAR;
BEGIN
    OPEN v_cur FOR
        SELECT sales_rep_id::VARCHAR AS sales_rep_src_id,
               sales_rep_first_name, sales_rep_last_name, sales_rep_email
        FROM bl_3nf.ce_employees
        WHERE sales_rep_id <> -1;

    LOOP
        FETCH v_cur INTO v_src_id, v_fname, v_lname, v_email;
        EXIT WHEN NOT FOUND;

        UPDATE bl_dm.dim_employees tgt
        SET sales_rep_first_name = v_fname,
            sales_rep_last_name  = v_lname,
            sales_rep_email      = v_email,
            update_dt = CURRENT_DATE
        WHERE tgt.sales_rep_src_id = v_src_id
          AND tgt.source_system    = 'BL_3NF'
          AND (tgt.sales_rep_first_name IS DISTINCT FROM v_fname
            OR tgt.sales_rep_last_name  IS DISTINCT FROM v_lname
            OR tgt.sales_rep_email      IS DISTINCT FROM v_email);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        INSERT INTO bl_dm.dim_employees (
            sales_rep_surr_id, sales_rep_first_name, sales_rep_last_name,
            sales_rep_email, source_system, source_entity, sales_rep_src_id,
            insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_employees_surr_id'),
               v_fname, v_lname, v_email, 'BL_3NF', 'CE_EMPLOYEES', v_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_employees tgt
            WHERE tgt.sales_rep_src_id = v_src_id AND tgt.source_system = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;
    CLOSE v_cur;   -- release the cursor
    CALL bl_cl.p_log('load_dim_employees', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (cursor variable)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_employees', 'ERROR', NULL, SQLERRM);
END;
$$;

-- DIM_LOCATIONS  UPSERT (INSERT ... ON CONFLICT)
-- ce_cities - ce_states - ce_countries


ALTER TABLE bl_dm.dim_locations
ADD CONSTRAINT uq_dim_locations_bk UNIQUE (city_name_src_id, source_system);

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_locations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_aff INT = 0;
BEGIN
    INSERT INTO bl_dm.dim_locations (
        city_surr_id, city_name, state_id, state, country_id, country_name,
        source_system, source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT
        nextval('bl_dm.seq_dim_locations_surr_id'),
        ci.city_name, st.state_id, st.state_name, cn.country_id, cn.country_name,
        'BL_3NF', 'CE_CITIES', ci.city_id::VARCHAR,
        CURRENT_DATE, CURRENT_DATE
    FROM bl_3nf.ce_cities ci
    JOIN bl_3nf.ce_states    st ON st.state_id   = ci.state_id
    JOIN bl_3nf.ce_countries cn ON cn.country_id = st.country_id
    WHERE ci.city_id <> -1
    ON CONFLICT (city_name_src_id, source_system) DO UPDATE
        SET city_name    = EXCLUDED.city_name,
            state_id     = EXCLUDED.state_id,
            state        = EXCLUDED.state,
            country_id   = EXCLUDED.country_id,
            country_name = EXCLUDED.country_name,
            update_dt    = CURRENT_DATE
        WHERE dim_locations.city_name    IS DISTINCT FROM EXCLUDED.city_name
           OR dim_locations.state        IS DISTINCT FROM EXCLUDED.state
           OR dim_locations.country_name IS DISTINCT FROM EXCLUDED.country_name;
    GET DIAGNOSTICS v_rows_aff = ROW_COUNT;

    CALL bl_cl.p_log('load_dim_locations', 'SUCCESS', v_rows_aff,
                     'Rows affected: ' || v_rows_aff || ' (upsert ON CONFLICT)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_locations', 'ERROR', NULL, SQLERRM);
END;
$$;

-- DIM_CUSTOMERS_SCD   SCD TYPE 2

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
BEGIN

    UPDATE bl_dm.dim_customers_scd tgt
    SET end_dt    = src.end_dt,
        is_active = src.is_active,
        update_dt = CURRENT_DATE
    FROM (SELECT customer_src_id, start_dt, end_dt, is_active
          FROM bl_3nf.ce_customers_scd
          WHERE customer_id <> -1) src
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.start_dt        = src.start_dt
      AND tgt.source_system   = 'BL_3NF'
      AND (tgt.end_dt    IS DISTINCT FROM src.end_dt
        OR tgt.is_active IS DISTINCT FROM src.is_active);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

    INSERT INTO bl_dm.dim_customers_scd (
        customer_surr_id, customer_first_name, customer_last_name, customer_email,
        customer_age, customer_gender, customer_segment, start_dt, end_dt, is_active,
        source_system, source_entity, customer_src_id, insert_dt, update_dt)
    SELECT nextval('bl_dm.seq_dim_customers_surr_id'),
           src.customer_first_name, src.customer_last_name, src.customer_email,
           src.customer_age, src.customer_gender, src.customer_segment,
           src.start_dt, src.end_dt, src.is_active,
           'BL_3NF', 'CE_CUSTOMERS_SCD', src.customer_src_id,
           CURRENT_DATE, CURRENT_DATE
    FROM (SELECT customer_src_id,
                 customer_first_name, customer_last_name, customer_email,
                 customer_age, customer_gender, customer_segment,
                 start_dt, end_dt, is_active
          FROM bl_3nf.ce_customers_scd
          WHERE customer_id <> -1) src
    WHERE NOT EXISTS (
        SELECT 1 FROM bl_dm.dim_customers_scd tgt
        WHERE tgt.customer_src_id = src.customer_src_id
          AND tgt.start_dt        = src.start_dt
          AND tgt.source_system   = 'BL_3NF');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_dim_customers_scd', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Synced: ' || v_rows_upd || ' (SCD2 mirror of 3NF)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_customers_scd', 'ERROR', NULL, SQLERRM);
END;
$$;
