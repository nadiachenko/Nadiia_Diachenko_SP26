CREATE SCHEMA IF NOT EXISTS bl_cl;

--ROLE AND PRIVILEGES

CREATE ROLE dwh_user LOGIN PASSWORD 'dwh';

GRANT USAGE ON SCHEMA sa_int_sales, sa_us_sales, bl_3nf, bl_cl TO dwh_user;

GRANT CREATE ON SCHEMA bl_cl TO dwh_user;

GRANT SELECT ON ALL TABLES IN SCHEMA sa_int_sales, sa_us_sales TO dwh_user;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bl_3nf, bl_cl TO dwh_user;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_3nf, bl_cl TO dwh_user;

GRANT EXECUTE ON ALL ROUTINES IN SCHEMA bl_cl TO dwh_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA sa_int_sales, sa_us_sales
    GRANT SELECT ON TABLES TO dwh_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_3nf, bl_cl
    GRANT SELECT, INSERT, UPDATE ON TABLES TO dwh_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_3nf, bl_cl
    GRANT USAGE, SELECT ON SEQUENCES TO dwh_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA bl_cl
    GRANT EXECUTE ON ROUTINES TO dwh_user;


-- LOGGING TABLE + LOGGING PROCEDURE + RETURNS TABLE FUNCTION to show logs

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

-- CE_CATEGORIES  
CREATE OR REPLACE PROCEDURE bl_cl.load_ce_categories()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_categories') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_categories does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_categories tgt
    SET product_category_name = src.category_name, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
          FROM sa_int_sales.src_int_sales WHERE category IS NOT NULL) src
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.product_category_name IS DISTINCT FROM src.category_name;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name,
        source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_categories_id'), src.category_name,
           'SA_INT_SALES', 'SRC_INT_SALES', src.category_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
          FROM sa_int_sales.src_int_sales WHERE category IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_categories tgt
        WHERE tgt.product_category_name_src_id = src.category_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_categories tgt
    SET product_category_name = src.category_name, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
          FROM sa_us_sales.src_us_sales WHERE product_category IS NOT NULL) src
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.product_category_name IS DISTINCT FROM src.category_name;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name,
        source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_categories_id'), src.category_name,
           'SA_US_SALES', 'SRC_US_SALES', src.category_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
              COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
          FROM sa_us_sales.src_us_sales WHERE product_category IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_categories tgt
        WHERE tgt.product_category_name_src_id = src.category_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_categories', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_categories', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_COUNTRIES

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_countries()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_countries') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_countries does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_countries tgt
    SET country_name = src.country_name, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') AS country_name,
              COALESCE(NULLIF(country, ''), 'n. a.') AS country_src_id
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    WHERE tgt.country_name_src_id = src.country_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.country_name IS DISTINCT FROM src.country_name;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_countries (country_id, country_name, source_system,
        source_entity, country_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_countries_id'), src.country_name,
           'SA_INT_SALES', 'SRC_INT_SALES', src.country_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') AS country_name,
              COALESCE(NULLIF(country, ''), 'n. a.') AS country_src_id
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_countries tgt
        WHERE tgt.country_name_src_id = src.country_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US - single 'US' country
    INSERT INTO bl_3nf.ce_countries (country_id, country_name, source_system,
        source_entity, country_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_countries_id'), 'US',
           'SA_US_SALES', 'SRC_US_SALES', 'US', CURRENT_DATE, CURRENT_DATE
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_countries tgt
        WHERE tgt.country_name_src_id = 'US' AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_countries', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_countries', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_CHANNELS(FOR LOOP)

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_channels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
    rec        RECORD;
BEGIN
     
    IF to_regclass('bl_3nf.ce_channels') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_channels does not exist!';
    END IF;

    FOR rec IN
        SELECT DISTINCT
            COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
            COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id,
            'SA_INT_SALES' AS source_system, 'SRC_INT_SALES' AS source_entity
        FROM sa_int_sales.src_int_sales WHERE channel IS NOT NULL
        UNION
        SELECT DISTINCT
            COALESCE(NULLIF(channel, ''), 'n. a.'),
            COALESCE(NULLIF(channel, ''), 'n. a.'),
            'SA_US_SALES', 'SRC_US_SALES'
        FROM sa_us_sales.src_us_sales WHERE channel IS NOT NULL
    LOOP
        UPDATE bl_3nf.ce_channels tgt
        SET channel = rec.channel_name, update_dt = CURRENT_DATE
        WHERE tgt.channel_src_id = rec.channel_src_id
          AND tgt.source_system = rec.source_system
          AND tgt.channel IS DISTINCT FROM rec.channel_name;
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

        INSERT INTO bl_3nf.ce_channels (channel_id, channel, source_system,
            source_entity, channel_src_id, insert_dt, update_dt)
        SELECT nextval('bl_3nf.seq_channels_id'), rec.channel_name,
               rec.source_system, rec.source_entity, rec.channel_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_channels tgt
            WHERE tgt.channel_src_id = rec.channel_src_id
              AND tgt.source_system = rec.source_system);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
    END LOOP;

    CALL bl_cl.p_log('load_ce_channels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (FOR loop)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_channels', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;


-- CE_EMPLOYEES  
CREATE OR REPLACE PROCEDURE bl_cl.load_ce_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_employees') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_employees does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_employees tgt
    SET sales_rep_first_name = src.first_name,
        sales_rep_last_name  = src.last_name,
        sales_rep_email      = src.email,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email_int, ''), 'n. a.')      AS email
          FROM sa_int_sales.src_int_sales WHERE sales_rep_id_int IS NOT NULL) src
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
        OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
        OR tgt.sales_rep_email      IS DISTINCT FROM src.email);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;
 INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name,
        sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_employees_id'), src.first_name, src.last_name, src.email,
           'SA_INT_SALES', 'SRC_INT_SALES', src.rep_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name_int, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name_int, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email_int, ''), 'n. a.')      AS email
          FROM sa_int_sales.src_int_sales WHERE sales_rep_id_int IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_employees tgt
        WHERE tgt.sales_rep_src_id = src.rep_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
  -- US
    UPDATE bl_3nf.ce_employees tgt
    SET sales_rep_first_name = src.first_name,
        sales_rep_last_name  = src.last_name,
        sales_rep_email      = src.email,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email, ''), 'n. a.')      AS email
          FROM sa_us_sales.src_us_sales WHERE sales_rep_id IS NOT NULL) src
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
        OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
        OR tgt.sales_rep_email      IS DISTINCT FROM src.email);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name,
        sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_employees_id'), src.first_name, src.last_name, src.email,
           'SA_US_SALES', 'SRC_US_SALES', src.rep_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(sales_rep_id, ''), 'n. a.')         AS rep_src_id,
              COALESCE(NULLIF(sales_rep_first_name, ''), 'n. a.') AS first_name,
              COALESCE(NULLIF(sales_rep_last_name, ''), 'n. a.')  AS last_name,
              COALESCE(NULLIF(sales_rep_email, ''), 'n. a.')      AS email
          FROM sa_us_sales.src_us_sales WHERE sales_rep_id IS NOT NULL) src
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_employees tgt
        WHERE tgt.sales_rep_src_id = src.rep_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;
   CALL bl_cl.p_log('load_ce_employees', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_employees', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_CUSTOMERS_SCD  

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_customers_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_exp INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_customers_scd') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_customers_scd does not exist!';
    END IF;

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
    CALL bl_cl.p_log('load_ce_customers_scd', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_SUBCATEGORIES 

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_subcategories()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_subcategories') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_subcategories does not exist!';
    END IF;
    IF to_regclass('bl_3nf.ce_categories') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_categories does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_subcategories tgt
    SET product_subcategory_name = src.subcategory_name,
        product_category_id = cat.product_category_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_int_sales.src_int_sales WHERE subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_INT_SALES'
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
        OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name,
        product_category_id, source_system, source_entity, product_subcategory_name_src_id,
        insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subcategories_id'), src.subcategory_name, cat.product_category_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.subcategory_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_int_sales.src_int_sales WHERE subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subcategories tgt
        WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_subcategories tgt
    SET product_subcategory_name = src.subcategory_name,
        product_category_id = cat.product_category_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_us_sales.src_us_sales WHERE product_subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_US_SALES'
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
        OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name,
        product_category_id, source_system, source_entity, product_subcategory_name_src_id,
        insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subcategories_id'), src.subcategory_name, cat.product_category_id,
           'SA_US_SALES', 'SRC_US_SALES', src.subcategory_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_category, ''), 'n. a.')    AS category_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
          FROM sa_us_sales.src_us_sales WHERE product_subcategory IS NOT NULL) src
    JOIN bl_3nf.ce_categories cat
        ON cat.product_category_name_src_id = src.category_name AND cat.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subcategories tgt
        WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_subcategories', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_subcategories', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;


-- CE_STATES ( synthetic state per country (name = country || '_state') is added to have ability to track country of the city further)

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_states()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_states') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_states does not exist!';
    END IF;
    IF to_regclass('bl_3nf.ce_countries') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_countries does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_states tgt
    SET state_name = src.state_name,
        country_id = cnt.country_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_name,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.')             AS country_key
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = src.country_key
       AND cnt.source_system = 'SA_INT_SALES'
    WHERE tgt.state_name_src_id = src.state_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.state_name IS DISTINCT FROM src.state_name
        OR tgt.country_id IS DISTINCT FROM cnt.country_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system,
        source_entity, state_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_states_id'), src.state_name, cnt.country_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.state_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_name,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.')             AS country_key
          FROM sa_int_sales.src_int_sales WHERE country IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = src.country_key
       AND cnt.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_states tgt
        WHERE tgt.state_name_src_id = src.state_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_states tgt
    SET state_name = src.state_name,
        country_id = cnt.country_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
          FROM sa_us_sales.src_us_sales WHERE state IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = 'US' AND cnt.source_system = 'SA_US_SALES'
    WHERE tgt.state_name_src_id = src.state_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.state_name IS DISTINCT FROM src.state_name
        OR tgt.country_id IS DISTINCT FROM cnt.country_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system,
        source_entity, state_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_states_id'), src.state_name, cnt.country_id,
           'SA_US_SALES', 'SRC_US_SALES', src.state_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
          FROM sa_us_sales.src_us_sales WHERE state IS NOT NULL) src
    JOIN bl_3nf.ce_countries cnt
        ON cnt.country_name_src_id = 'US' AND cnt.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_states tgt
        WHERE tgt.state_name_src_id = src.state_src_id
          AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_states', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_states', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_SUBCHANNELS  

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_subchannels()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_subchannels') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_subchannels does not exist!';
    END IF;
    IF to_regclass('bl_3nf.ce_channels') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_channels does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_subchannels tgt
    SET subchannel = src.subchannel_name, channel_id = ch.channel_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_int_sales.src_int_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_INT_SALES'
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.subchannel IS DISTINCT FROM src.subchannel_name
        OR tgt.channel_id IS DISTINCT FROM ch.channel_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system,
        source_entity, subchannel_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subchannels_id'), src.subchannel_name, ch.channel_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.subchannel_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_int_sales.src_int_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subchannels tgt
        WHERE tgt.subchannel_src_id = src.subchannel_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_subchannels tgt
    SET subchannel = src.subchannel_name, channel_id = ch.channel_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_us_sales.src_us_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_US_SALES'
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND (tgt.subchannel IS DISTINCT FROM src.subchannel_name
        OR tgt.channel_id IS DISTINCT FROM ch.channel_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system,
        source_entity, subchannel_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_subchannels_id'), src.subchannel_name, ch.channel_id,
           'SA_US_SALES', 'SRC_US_SALES', src.subchannel_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(channel, ''), 'n. a.')    AS channel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
              COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
          FROM sa_us_sales.src_us_sales WHERE subchannel IS NOT NULL) src
    JOIN bl_3nf.ce_channels ch
        ON ch.channel_src_id = src.channel_name AND ch.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_subchannels tgt
        WHERE tgt.subchannel_src_id = src.subchannel_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_subchannels', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_subchannels', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_PRODUCTS  (child of subcategories; INT + US)

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_products') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_products does not exist!';
    END IF;
    IF to_regclass('bl_3nf.ce_subcategories') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_subcategories does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_products tgt
    SET product_subcategory_id = sub.product_subcategory_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
              COALESCE(NULLIF(subcategory, ''), 'n. a.')    AS subcategory_name
          FROM sa_int_sales.src_int_sales WHERE product_id_int IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_INT_SALES'
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system,
        source_entity, product_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_products_id'), sub.product_subcategory_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.product_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
              COALESCE(NULLIF(subcategory, ''), 'n. a.')    AS subcategory_name
          FROM sa_int_sales.src_int_sales WHERE product_id_int IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products tgt
        WHERE tgt.product_src_id = src.product_src_id AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_products tgt
    SET product_subcategory_id = sub.product_subcategory_id, update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
          FROM sa_us_sales.src_us_sales WHERE product_id IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_US_SALES'
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system,
        source_entity, product_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_products_id'), sub.product_subcategory_id,
           'SA_US_SALES', 'SRC_US_SALES', src.product_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
              COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
          FROM sa_us_sales.src_us_sales WHERE product_id IS NOT NULL) src
    JOIN bl_3nf.ce_subcategories sub
        ON sub.product_subcategory_name_src_id = src.subcategory_name AND sub.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_products tgt
        WHERE tgt.product_src_id = src.product_src_id AND tgt.source_system = 'SA_US_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_products', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_products', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;

-- CE_CITIES  (INT:  city is linked to synthetic state via country || '_state')

CREATE OR REPLACE PROCEDURE bl_cl.load_ce_cities()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT := 0;
    v_rows_upd INT := 0;
    v_tmp      INT := 0;
BEGIN
     
    IF to_regclass('bl_3nf.ce_cities') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_cities does not exist!';
    END IF;
    IF to_regclass('bl_3nf.ce_states') IS NULL THEN
        RAISE EXCEPTION 'Prerequisite table bl_3nf.ce_states does not exist!';
    END IF;

    -- INT
    UPDATE bl_3nf.ce_cities tgt
    SET city_name = src.city_name,
        state_id = st.state_id,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_name,
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_key
          FROM sa_int_sales.src_int_sales WHERE city_int IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_key
       AND st.source_system = 'SA_INT_SALES'
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND (tgt.city_name IS DISTINCT FROM src.city_name
        OR tgt.state_id IS DISTINCT FROM st.state_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system,
        source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_cities_id'), src.city_name, st.state_id,
           'SA_INT_SALES', 'SRC_INT_SALES', src.city_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_name,
              COALESCE(NULLIF(city_int, ''), 'n. a.')            AS city_src_id,
              COALESCE(NULLIF(country, ''), 'n. a.') || '_state' AS state_key
          FROM sa_int_sales.src_int_sales WHERE city_int IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_key
       AND st.source_system = 'SA_INT_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_cities tgt
        WHERE tgt.city_name_src_id = src.city_src_id
          AND tgt.source_system = 'SA_INT_SALES');
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    -- US
    UPDATE bl_3nf.ce_cities tgt
    SET city_name = src.city_name,
        update_dt = CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_src_id
          FROM sa_us_sales.src_us_sales WHERE city IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_name
       AND st.source_system = 'SA_US_SALES'
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.state_id = st.state_id
      AND (tgt.city_name IS DISTINCT FROM src.city_name);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd := v_rows_upd + v_tmp;

    INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system,
        source_entity, city_name_src_id, insert_dt, update_dt)
    SELECT nextval('bl_3nf.seq_cities_id'), src.city_name, st.state_id,
           'SA_US_SALES', 'SRC_US_SALES', src.city_src_id, CURRENT_DATE, CURRENT_DATE
    FROM (SELECT DISTINCT
              COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_name,
              COALESCE(NULLIF(city, ''), 'n. a.')  AS city_src_id
          FROM sa_us_sales.src_us_sales WHERE city IS NOT NULL) src
    JOIN bl_3nf.ce_states st
        ON st.state_name_src_id = src.state_name
       AND st.source_system = 'SA_US_SALES'
    WHERE NOT EXISTS (SELECT 1 FROM bl_3nf.ce_cities tgt
        WHERE tgt.city_name_src_id = src.city_src_id
          AND tgt.source_system = 'SA_US_SALES'
          AND tgt.state_id = st.state_id);
    GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins := v_rows_ins + v_tmp;

    CALL bl_cl.p_log('load_ce_cities', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_ce_cities', 'ERROR', NULL, SQLERRM, SQLSTATE);
END;
$$;


    CALL bl_cl.load_ce_categories();
    CALL bl_cl.load_ce_countries();
    CALL bl_cl.load_ce_channels();
    CALL bl_cl.load_ce_employees();
    CALL bl_cl.load_ce_customers_scd();
    CALL bl_cl.load_ce_subcategories();
    CALL bl_cl.load_ce_states();
    CALL bl_cl.load_ce_subchannels();
    CALL bl_cl.load_ce_products();
    CALL bl_cl.load_ce_cities();
