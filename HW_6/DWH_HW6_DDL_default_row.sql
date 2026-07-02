--is_active attribute of ce_customers_scd data type is changed to varchar(1) to follow standarts(was boolean)


--STEP 1: Create 3nf schema

CREATE SCHEMA IF NOT EXISTS bl_3nf;

--STEP 2: Sequences generation for each table

CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_categories_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_subcategories_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_products_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_countries_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_states_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_cities_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_channels_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_subchannels_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_customers_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_employees_id START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_orders_id START WITH 100 INCREMENT BY 1;


--STEP 3: Tables creation

--CE_CATEGORIES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_categories (
    product_category_id BIGINT NOT NULL,
    product_category_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    product_category_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_categories PRIMARY KEY (product_category_id)
);

--CE_SUBCATEGORIES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_subcategories (
    product_subcategory_id BIGINT NOT NULL,
    product_subcategory_name VARCHAR NOT NULL,
    product_category_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    product_subcategory_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_subcategories PRIMARY KEY (product_subcategory_id),
    CONSTRAINT fk_ce_subcategories_cat FOREIGN KEY (product_category_id) 
        REFERENCES bl_3nf.ce_categories(product_category_id)
);

--CE_PRODUCTS
CREATE TABLE IF NOT EXISTS bl_3nf.ce_products (
    product_id BIGINT NOT NULL,
    product_subcategory_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    product_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_products PRIMARY KEY (product_id),
    CONSTRAINT fk_ce_products_subcat FOREIGN KEY (product_subcategory_id) 
        REFERENCES bl_3nf.ce_subcategories(product_subcategory_id)
);

--CE_COUNTRIES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_countries (
    country_id BIGINT NOT NULL,
    country_name VARCHAR NOT NULL,
    state_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    country_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_countries PRIMARY KEY (country_id)
);

--CE_STATES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_states (
    state_id BIGINT NOT NULL,
    state_name VARCHAR NOT NULL,
    country_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    state_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_states PRIMARY KEY (state_id),
    CONSTRAINT fk_ce_states_country FOREIGN KEY (country_id) 
        REFERENCES bl_3nf.ce_countries(country_id)
);

--CE_CITIES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_cities (
    city_id BIGINT NOT NULL,
    city_name VARCHAR NOT NULL,
    state_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    city_name_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_cities PRIMARY KEY (city_id),
    CONSTRAINT fk_ce_cities_state FOREIGN KEY (state_id) 
        REFERENCES bl_3nf.ce_states(state_id)
);

--CE_CHANNELS
CREATE TABLE IF NOT EXISTS bl_3nf.ce_channels (
    channel_id BIGINT NOT NULL,
    channel VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    channel_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_channels PRIMARY KEY (channel_id)
);

--CE_SUBCHANNELS
CREATE TABLE IF NOT EXISTS bl_3nf.ce_subchannels (
    subchannel_id BIGINT NOT NULL,
    subchannel VARCHAR NOT NULL,
    channel_id BIGINT NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    subchannel_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_subchannels PRIMARY KEY (subchannel_id),
    CONSTRAINT fk_ce_subchannels_chan FOREIGN KEY (channel_id) 
        REFERENCES bl_3nf.ce_channels(channel_id)
);

--CE_EMPLOYEES
CREATE TABLE IF NOT EXISTS bl_3nf.ce_employees (
    sales_rep_id BIGINT NOT NULL,
    sales_rep_first_name VARCHAR NOT NULL,
    sales_rep_last_name VARCHAR NOT NULL,
    sales_rep_email VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    sales_rep_src_id VARCHAR NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_employees PRIMARY KEY (sales_rep_id)
);

--CE_CUSTOMERS_SCD
CREATE TABLE IF NOT EXISTS bl_3nf.ce_customers_scd (
    customer_id BIGINT NOT NULL,
    customer_first_name VARCHAR NOT NULL,
    customer_last_name VARCHAR NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_age VARCHAR NOT NULL,
    customer_gender VARCHAR NOT NULL,
    customer_segment VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    customer_src_id VARCHAR NOT NULL,
    is_active VARCHAR(1) NOT NULL,
    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    CONSTRAINT pk_ce_customers_scd PRIMARY KEY (customer_id, start_dt)
);

--CE_ORDERS
CREATE TABLE IF NOT EXISTS bl_3nf.ce_orders (
    order_id BIGINT NOT NULL,
    order_dt DATE NOT NULL,
    order_status VARCHAR NOT NULL,
    returned VARCHAR NOT NULL,
    customer_id BIGINT NOT NULL,
    sales_rep_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    channel_id BIGINT NOT NULL,
    country_id BIGINT NOT NULL,
    payment_method VARCHAR NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity BIGINT NOT NULL,
    discount_percent BIGINT NOT NULL,
    discount_amount NUMERIC(10,2) NOT NULL,
    shipping_cost NUMERIC(10,2) NOT NULL,
    tax_amount NUMERIC(10,2) NOT NULL,
    order_amount NUMERIC(10,2) NOT NULL,
    cost_amount NUMERIC(10,2) NOT NULL,
    profit_margin_percent NUMERIC(10,2) NOT NULL,
    profit_amount NUMERIC(10,2) NOT NULL,
    transaction_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_ce_orders_employee FOREIGN KEY (sales_rep_id) REFERENCES bl_3nf.ce_employees(sales_rep_id),
    CONSTRAINT fk_ce_orders_product FOREIGN KEY (product_id) REFERENCES bl_3nf.ce_products(product_id),
    CONSTRAINT fk_ce_orders_channel FOREIGN KEY (channel_id) REFERENCES bl_3nf.ce_channels(channel_id),
    CONSTRAINT fk_ce_orders_country FOREIGN KEY (country_id) REFERENCES bl_3nf.ce_countries(country_id)
);

--STEP 4: Default rows injection

BEGIN;

--CE_CATEGORIES
INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name, source_system, source_entity, product_category_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (product_category_id) DO NOTHING;

--CE_SUBCATEGORIES
INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name, product_category_id, source_system, source_entity, product_subcategory_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (product_subcategory_id) DO NOTHING;

--CE_PRODUCTS
INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system, source_entity, product_src_id, insert_dt, update_dt) 
VALUES (-1, -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (product_id) DO NOTHING;

--CE_COUNTRIES
INSERT INTO bl_3nf.ce_countries (country_id, country_name, state_id, source_system, source_entity, country_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (country_id) DO NOTHING;

--CE_STATES
INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system, source_entity, state_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (state_id) DO NOTHING;

--CE_CITIES
INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system, source_entity, city_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (city_id) DO NOTHING;

--CE_CHANNELS
INSERT INTO bl_3nf.ce_channels (channel_id, channel, source_system, source_entity, channel_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (channel_id) DO NOTHING;

--CE_SUBCHANNELS
INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system, source_entity, subchannel_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (subchannel_id) DO NOTHING;

--CE_EMPLOYEES
INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name, sales_rep_email, source_system, source_entity, sales_rep_src_id, update_dt) 
VALUES (-1, 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01') 
ON CONFLICT (sales_rep_id) DO NOTHING;

--CE_CUSTOMERS_SCD
INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name, customer_email, customer_age, customer_gender, customer_segment, source_system, source_entity, customer_src_id, is_active, start_dt, end_dt) 
VALUES (-1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', 'Y', '1900-01-01', '9999-12-31') 
ON CONFLICT (customer_id, start_dt) DO NOTHING;

COMMIT;
