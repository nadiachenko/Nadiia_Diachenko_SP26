-- STEP 1: SCHEMA GENERATION & CLEANUP
CREATE SCHEMA IF NOT EXISTS bl_dm;

-- STEP 2: INITIALIZE SEQUENCES
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_products_surr_id START WITH 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_customers_surr_id START WITH 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_employees_surr_id START WITH 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_geographies_surr_id START WITH 1;
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_channels_surr_id START WITH 1;


-- STEP 3: TABLES CREATION
-- DIM_PRODUCTS 
CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
    product_surr_id BIGINT NOT NULL,   
    product_subcategory_id BIGINT NOT NULL,
    product_subcategory_name VARCHAR NOT NULL,
    product_category_id BIGINT NOT NULL,
    product_category_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    product_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_products PRIMARY KEY (product_surr_id)
);

-- DIM_LOCATIONS 
CREATE TABLE IF NOT EXISTS bl_dm.dim_locations (
    city_surr_id BIGINT NOT NULL,
    city_name VARCHAR NOT NULL,
    state_id BIGINT NOT NULL,
    state VARCHAR NOT NULL,
    country_id BIGINT NOT NULL,
    country_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    CITY_nameSRC_ID VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_locations PRIMARY KEY (city_surr_id)
);

-- DIM_CHANNELS 
CREATE TABLE IF NOT EXISTS bl_dm.dim_channels (
    subchannel_surr_id BIGINT NOT NULL,
    subchannel VARCHAR NOT NULL,
    channel_id BIGINT NOT NULL,
    channel VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    subchannel_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_channels PRIMARY KEY (subchannel_surr_id)
);


-- STEP 5: DIM_EMPLOYEES
CREATE TABLE IF NOT EXISTS bl_dm.dim_employees (
    sales_rep_surr_id BIGINT NOT NULL,
    sales_rep_first_name VARCHAR NOT NULL,
    sales_rep_last_name VARCHAR NOT NULL,
    sales_rep_email VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    sales_rep_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_employees PRIMARY KEY (sales_rep_surr_id)
);


-- STEP 6: DIM_CUSTOMERS_SCD (SCD2 Dimension)
CREATE TABLE IF NOT EXISTS bl_dm.dim_customers_scd (
    customer_surr_id BIGINT NOT NULL,
    customer_first_name VARCHAR NOT NULL,
    customer_last_name VARCHAR NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_age VARCHAR NOT NULL,
    customer_gender VARCHAR NOT NULL,
    customer_segment VARCHAR NOT NULL,
    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    is_active VARCHAR(1) NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    customer_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_customers_scd PRIMARY KEY (customer_surr_id)
);

-- DIM_ORDER_DETAILS

CREATE TABLE IF NOT EXISTS bl_dm.dim_orders_details (
    order_surr_id BIGINT NOT NULL,
    order_status VARCHAR NOT NULL,
    returned VARCHAR NOT NULL,
    payment_method VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    order_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_orders_details PRIMARY KEY (order_surr_id)
);

-- FCT_ORDERS_DD
CREATE TABLE IF NOT EXISTS bl_dm.fct_orders_dd (
    order_surr_id BIGINT NOT NULL,
    event_dt DATE NOT NULL,
    product_surr_id BIGINT NOT NULL,
    customer_surr_id BIGINT NOT NULL,
    sales_rep_surr_id BIGINT NOT NULL,
    city_surr_id BIGINT NOT NULL,
    subchannel_surr_id BIGINT NOT NULL,
    order_status VARCHAR NOT NULL,
    returned VARCHAR NOT NULL,
    payment_method VARCHAR NOT NULL,
    fct_unit_price NUMERIC(10,2) NOT NULL,
    fct_quantity BIGINT NOT NULL,
    fct_discount_percent BIGINT NOT NULL,
    fct_discount_amount NUMERIC(10,2) NOT NULL,
    fct_shipping_cost NUMERIC(10,2) NOT NULL,
    fct_tax_amount NUMERIC(10,2) NOT NULL,
    fct_order_amount NUMERIC(10,2) NOT NULL,
    fct_cost_amount NUMERIC(10,2) NOT NULL,
    fct_profit_margin_percent NUMERIC(10,2) NOT NULL,
    fct_profit_amount NUMERIC(10,2) NOT NULL,
    fct_net_amount NUMERIC(10,2) NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    order_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    
    CONSTRAINT fk_fct_orders_to_products FOREIGN KEY (product_surr_id) REFERENCES bl_dm.dim_products (product_surr_id),
    CONSTRAINT fk_fct_orders_to_customers FOREIGN KEY (customer_surr_id) REFERENCES bl_dm.dim_customers_scd (customer_surr_id),
    CONSTRAINT fk_fct_orders_to_employees FOREIGN KEY (sales_rep_surr_id) REFERENCES bl_dm.dim_employees (sales_rep_surr_id),
    CONSTRAINT fk_fct_orders_to_locations foreign KEY (city_surr_id) REFERENCES bl_dm.dim_locations (city_surr_id),
    CONSTRAINT fk_fct_orders_to_channels FOREIGN KEY (subchannel_surr_id) REFERENCES bl_dm.dim_channels (subchannel_surr_id)
);


-- STEP 8: DEFAULT ROWS INITIALIZATION

BEGIN;
INSERT INTO bl_dm.dim_products (
    product_surr_id, product_src_id, product_subcategory_id, product_subcategory_name,
    product_category_id, product_category_name, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products WHERE product_surr_id = -1);

INSERT INTO bl_dm.dim_locations (
    city_surr_id, city_name_src_id, city, state_id, state, 
    country_id, country_name, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, -1, 'n. a.', -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_locations WHERE city_surr_id = -1);

INSERT INTO bl_dm.dim_channels (
    subchannel_surr_id, subchannel_src_id, subchannel, channel_id, channel, 
    source_system, source_entity, insert_dt, update_dt
)
SELECT -1, -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_channels WHERE subchannel_surr_id = -1);

INSERT INTO bl_dm.dim_employees (
    sales_rep_surr_id, sales_rep_src_id, sales_rep_first_name, sales_rep_last_name, 
    sales_rep_email, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_employees WHERE sales_rep_surr_id = -1);

INSERT INTO bl_dm.dim_customers_scd (
    customer_surr_id, customer_src_id, customer_first_name, customer_last_name, 
    customer_email, customer_age, customer_gender, customer_segment, 
    start_dt, end_dt, is_active, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 
       '1900-01-01'::DATE, '9999-12-31'::DATE, 'Y', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_customers_scd WHERE customer_surr_id = -1);

INSERT INTO bl_dm.dim_orders_details (
    order_surr_id, order_status, returned, payment_method, 
    source_system, source_entity, order_src_id, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_orders_details WHERE order_surr_id = -1);

COMMIT;