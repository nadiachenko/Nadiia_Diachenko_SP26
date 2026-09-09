-- CE_CATEGORIES: International
BEGIN;
INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name, source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_categories_id'),
    src.category_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.category_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(category, ''), 'n. a.') as category_name,
        COALESCE(NULLIF(category, ''), 'n. a.') as category_src_id
    FROM sa_int_sales.src_int_sales
    WHERE category IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_categories bl_3nf 
    WHERE bl_3nf.product_category_name_src_id = src.category_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_CATEGORIES: United States
BEGIN;
INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name, source_system, source_entity, product_category_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_categories_id'),
    src.category_name,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.category_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(product_category, ''), 'n. a.') as category_name,
        COALESCE(NULLIF(product_category, ''), 'n. a.') as category_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_category IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_categories bl_3nf 
    WHERE bl_3nf.product_category_name_src_id = src.category_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_COUNTRIES: International (Fixed: Removed state_id mapping)
BEGIN;
INSERT INTO bl_3nf.ce_countries (country_id, country_name, source_system, source_entity, country_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_countries_id'),
    src.country_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.country_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(country, ''), 'n. a.') as country_name,
        COALESCE(NULLIF(country, ''), 'n. a.') as country_src_id
    FROM sa_int_sales.src_int_sales
    WHERE country IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_countries bl_3nf 
    WHERE bl_3nf.country_name_src_id = src.country_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_COUNTRIES: United States (Fixed: Removed state_id mapping)
BEGIN;
INSERT INTO bl_3nf.ce_countries (country_id, country_name, source_system, source_entity, country_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_countries_id'),
    'US',
    'SA_US_SALES',
    'SRC_US_SALES',
    'US',
    CURRENT_DATE,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_countries bl_3nf 
    WHERE bl_3nf.country_name_src_id = 'US' 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_CHANNELS: International
BEGIN;
INSERT INTO bl_3nf.ce_channels (channel_id, channel, source_system, source_entity, channel_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_channels_id'),
    src.channel_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.channel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(channel, ''), 'n. a.') as channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') as channel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE channel IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_channels bl_3nf 
    WHERE bl_3nf.channel_src_id = src.channel_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_CHANNELS: United States
BEGIN;
INSERT INTO bl_3nf.ce_channels (channel_id, channel, source_system, source_entity, channel_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_channels_id'),
    src.channel_name,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.channel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(channel, ''), 'n. a.') as channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') as channel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE channel IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_channels bl_3nf 
    WHERE bl_3nf.channel_src_id = src.channel_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_EMPLOYEES: International (Fixed: Added insert_dt mapping)
BEGIN;
INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name, sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_employees_id'),
    src.first_name,
    src.last_name,
    src.email,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.rep_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(SALES_REP_ID_INT, ''), 'n. a.') as rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME_INT, ''), 'n. a.') as first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME_INT, ''), 'n. a.') as last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL_INT, ''), 'n. a.') as email
    FROM sa_int_sales.src_int_sales
    WHERE SALES_REP_ID_INT IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_employees bl_3nf 
    WHERE bl_3nf.sales_rep_src_id = src.rep_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_EMPLOYEES: United States (Fixed: Added insert_dt mapping)
BEGIN;
INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name, sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_employees_id'),
    src.first_name,
    src.last_name,
    src.email,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.rep_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(SALES_REP_ID, ''), 'n. a.') as rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME, ''), 'n. a.') as first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME, ''), 'n. a.') as last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL, ''), 'n. a.') as email
    FROM sa_us_sales.src_us_sales
    WHERE SALES_REP_ID IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_employees bl_3nf 
    WHERE bl_3nf.sales_rep_src_id = src.rep_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_SUBCATEGORIES: International
BEGIN;
INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name, product_category_id, source_system, source_entity, product_subcategory_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_subcategories_id'),
    src.subcategory_name,
    COALESCE(cat.product_category_id, -1),
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.subcategory_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(subcategory, ''), 'n. a.') as subcategory_name,
        COALESCE(NULLIF(category, ''), 'n. a.') as parent_category_name,
        COALESCE(NULLIF(subcategory, ''), 'n. a.') as subcategory_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subcategory IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_categories cat 
    ON cat.product_category_name_src_id = src.parent_category_name 
   AND cat.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_subcategories bl_3nf 
    WHERE bl_3nf.product_subcategory_name_src_id = src.subcategory_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_SUBCATEGORIES: United States
BEGIN;
INSERT INTO bl_3nf.ce_subcategories (product_subcategory_id, product_subcategory_name, product_category_id, source_system, source_entity, product_subcategory_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_subcategories_id'),
    src.subcategory_name,
    COALESCE(cat.product_category_id, -1),
    'SA_US_SALES',
    'SRC_US_SALES',
    src.subcategory_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') as subcategory_name,
        COALESCE(NULLIF(product_category, ''), 'n. a.') as parent_category_name,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') as subcategory_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_subcategory IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_categories cat 
    ON cat.product_category_name_src_id = src.parent_category_name 
   AND cat.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_subcategories bl_3nf 
    WHERE bl_3nf.product_subcategory_name_src_id = src.subcategory_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_STATES: International
BEGIN;
INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system, source_entity, state_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_states_id'),
    'n. a.',
    -1, 
    'SA_INT_SALES',
    'SRC_INT_SALES',
    'n. a.',
    CURRENT_DATE,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_states bl_3nf 
    WHERE bl_3nf.state_name_src_id = 'n. a.' 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_STATES: United States
BEGIN;
INSERT INTO bl_3nf.ce_states (state_id, state_name, country_id, source_system, source_entity, state_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_states_id'),
    src.state_name,
    COALESCE(c.country_id, -1),
    'SA_US_SALES',
    'SRC_US_SALES',
    src.state_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(STATE, ''), 'n. a.') as state_name,
        'US' as country_name,
        COALESCE(NULLIF(STATE, ''), 'n. a.') as state_src_id
    FROM sa_us_sales.src_us_sales
    WHERE STATE IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_countries c 
    ON c.country_name_src_id = src.country_name 
   AND c.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_states bl_3nf 
    WHERE bl_3nf.state_name_src_id = src.state_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_PRODUCTS: International Source
BEGIN;
INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system, source_entity, product_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_products_id'),
    COALESCE(sub.product_subcategory_id, -1),
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.product_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(PRODUCT_ID_INT, ''), 'n. a.') as product_src_id,
        COALESCE(NULLIF(SUBCATEGORY, ''), 'n. a.') as subcategory_name
    FROM sa_int_sales.src_int_sales
    WHERE PRODUCT_ID_INT IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_subcategories sub 
    ON sub.product_subcategory_name_src_id = src.subcategory_name 
   AND sub.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_products bl_3nf 
    WHERE bl_3nf.product_src_id = src.product_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_PRODUCTS: United States Source
BEGIN;
INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system, source_entity, product_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_products_id'),
    COALESCE(sub.product_subcategory_id, -1),
    'SA_US_SALES',
    'SRC_US_SALES',
    src.product_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(PRODUCT_ID, ''), 'n. a.') as product_src_id,
        COALESCE(NULLIF(PRODUCT_SUBCATEGORY, ''), 'n. a.') as subcategory_name
    FROM sa_us_sales.src_us_sales
    WHERE PRODUCT_ID IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_subcategories sub 
    ON sub.product_subcategory_name_src_id = src.subcategory_name 
   AND sub.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_products bl_3nf 
    WHERE bl_3nf.product_src_id = src.product_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_CITIES: International
BEGIN;
INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system, source_entity, city_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_cities_id'),
    src.city_name,
    COALESCE(st.state_id, -1),
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.city_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(city_int, ''), 'n. a.') as city_name,
        'n. a.' as state_name,
        COALESCE(NULLIF(city_int, ''), 'n. a.') as city_src_id
    FROM sa_int_sales.src_int_sales
    WHERE city_int IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_states st 
    ON st.state_name_src_id = src.state_name 
   AND st.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_cities bl_3nf 
    WHERE bl_3nf.city_name_src_id = src.city_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_CITIES: United States
BEGIN;
INSERT INTO bl_3nf.ce_cities (city_id, city_name, state_id, source_system, source_entity, city_name_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_cities_id'),
    src.city_name,
    COALESCE(st.state_id, -1),
    'SA_US_SALES',
    'SRC_US_SALES',
    src.city_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(city, ''), 'n. a.') as city_name,
        COALESCE(NULLIF(state, ''), 'n. a.') as state_name,
        COALESCE(NULLIF(city, ''), 'n. a.') as city_src_id
    FROM sa_us_sales.src_us_sales
    WHERE city IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_states st 
    ON st.state_name_src_id = src.state_name 
   AND st.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_cities bl_3nf 
    WHERE bl_3nf.city_name_src_id = src.city_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_SUBCHANNELS: International
BEGIN;
INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system, source_entity, subchannel_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_subchannels_id'),
    src.subchannel,
    COALESCE(ch.channel_id, -1),
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.subchannel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(subchannel, ''), 'n. a.') as subchannel,
        COALESCE(NULLIF(channel, ''), 'n. a.') as channel_id,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') as subchannel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subchannel IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_channels ch 
    ON ch.channel_src_id = src.channel_id
   AND ch.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_subchannels bl_3nf 
    WHERE bl_3nf.subchannel_src_id = src.subchannel_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_SUBCHANNELS: United States
BEGIN;
INSERT INTO bl_3nf.ce_subchannels (subchannel_id, subchannel, channel_id, source_system, source_entity, subchannel_src_id, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_subchannels_id'),
    src.subchannel_name,
    COALESCE(ch.channel_id, -1),
    'SA_US_SALES',
    'SRC_US_SALES',
    src.subchannel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(SUBCHANNEL, ''), 'n. a.') as subchannel_name,
        COALESCE(NULLIF(CHANNEL, ''), 'n. a.') as channel_name,
        COALESCE(NULLIF(SUBCHANNEL, ''), 'n. a.') as subchannel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE SUBCHANNEL IS NOT NULL
) src
LEFT JOIN bl_3nf.ce_channels ch 
    ON ch.channel_src_id = src.channel_name 
   AND ch.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_subchannels bl_3nf 
    WHERE bl_3nf.subchannel_src_id = src.subchannel_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_CUSTOMERS_SCD: International (Fixed: Added insert_dt and update_dt fields)
BEGIN;
INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name, customer_email, customer_age, customer_gender, customer_segment, source_system, source_entity, customer_src_id, is_active, start_dt, end_dt, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_customers_id'),
    src.first_name,
    src.last_name,
    src.email,
    src.age,
    src.gender,
    src.segment,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.cust_src_id,
    'Y',
    '1900-01-01'::DATE,
    '9999-12-31'::DATE,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(CUSTOMER_ID_INT, ''), 'n. a.') as cust_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME_INT, ''), 'n. a.') as first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME_INT, ''), 'n. a.') as last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL_INT, ''), 'n. a.') as email,
        'n. a.' as age,     
        'n. a.' as gender,  
        'n. a.' as segment  
    FROM sa_int_sales.src_int_sales
    WHERE CUSTOMER_ID_INT IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_customers_scd bl_3nf 
    WHERE bl_3nf.customer_src_id = src.cust_src_id 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;

-- CE_CUSTOMERS_SCD: United States (Fixed: Added insert_dt and update_dt fields)
BEGIN;
INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name, customer_email, customer_age, customer_gender, customer_segment, source_system, source_entity, customer_src_id, is_active, start_dt, end_dt, insert_dt, update_dt)
SELECT 
    nextval('bl_3nf.seq_customers_id'),
    src.first_name,
    src.last_name,
    src.email,
    src.age,
    src.gender,
    src.segment,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.cust_src_id,
    'Y',
    '1900-01-01'::DATE,
    '9999-12-31'::DATE,
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT 
        COALESCE(NULLIF(CUSTOMER_ID, ''), 'n. a.') as cust_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME, ''), 'n. a.') as first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME, ''), 'n. a.') as last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL, ''), 'n. a.') as email,
        COALESCE(NULLIF(CUSTOMER_AGE, ''), 'n. a.') as age,
        COALESCE(NULLIF(CUSTOMER_GENDER, ''), 'n. a.') as gender,
        COALESCE(NULLIF(CUSTOMER_SEGMENT, ''), 'n. a.') as segment
    FROM sa_us_sales.src_us_sales
    WHERE CUSTOMER_ID IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_customers_scd bl_3nf 
    WHERE bl_3nf.customer_src_id = src.cust_src_id 
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;

-- CE_ORDERS: INTERNATIONAL (Fixed: Grain changed to subchannel_id and city_id; mapped lineage and order_src_id)
BEGIN;
INSERT INTO bl_3nf.ce_orders (
    order_id, order_dt, order_status, returned, customer_id, sales_rep_id, 
    product_id, subchannel_id, city_id, payment_method, unit_price, quantity, 
    discount_percent, discount_amount, shipping_cost, tax_amount, order_amount, 
    cost_amount, profit_margin_percent, profit_amount, transaction_id, 
    source_system, source_entity, order_src_id, insert_dt, update_dt
)
SELECT 
    nextval('bl_3nf.seq_orders_id'),
    COALESCE(TO_DATE(stg.ORDER_DT_INT, 'YYYY-MM-DD'), '1900-01-01'::DATE),
    COALESCE(stg.ORDER_STATUS_INT, 'n. a.'),
    COALESCE(stg.RETURNED, 'n. a.'),
    COALESCE(cust.customer_id, -1),
    COALESCE(emp.sales_rep_id, -1),
    COALESCE(prod.product_id, -1),
    COALESCE(sub.subchannel_id, -1),
    COALESCE(cit.city_id, -1),
    COALESCE(stg.PAYMENT, 'n. a.'),
    COALESCE(NULLIF(stg.PRICE, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.QUANTITY_INT, '')::BIGINT, 0),
    COALESCE(NULLIF(stg.DISCOUNT_PERCENT_INT, '')::BIGINT, 0),
    COALESCE(NULLIF(stg.DISCOUNT_AMOUNT_INT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.SHIPPING_COST_INT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.TAX, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.ORDER_AMOUNT_INT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.COST_AMOUNT_INT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.PPROFIT_MARGIN_PERCENT_INT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.PROFIT_AMOUNT_INT, '')::NUMERIC(10,2), 0.00),
    stg.ORDER_ID_INT,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    stg.ORDER_ID_INT,
    CURRENT_DATE,
    CURRENT_DATE
FROM sa_int_sales.src_int_sales stg
LEFT JOIN bl_3nf.ce_customers_scd cust 
    ON cust.customer_src_id = stg.CUSTOMER_ID_INT 
   AND cust.source_system = 'SA_INT_SALES' 
   AND cust.is_active = 'Y'
LEFT JOIN bl_3nf.ce_employees emp 
    ON emp.sales_rep_src_id = stg.SALES_REP_ID_INT 
   AND emp.source_system = 'SA_INT_SALES'
LEFT JOIN bl_3nf.ce_products prod 
    ON prod.product_src_id = stg.PRODUCT_ID_INT 
   AND prod.source_system = 'SA_INT_SALES'
LEFT JOIN bl_3nf.ce_subchannels sub 
    ON sub.subchannel_src_id = stg.SUBCHANNEL 
   AND sub.source_system = 'SA_INT_SALES'
LEFT JOIN bl_3nf.ce_countries cnt 
    ON cnt.country_name_src_id = stg.COUNTRY 
   AND cnt.source_system = 'SA_INT_SALES'
LEFT JOIN bl_3nf.ce_states state
    ON state.state_name_src_id = 'n. a.'
   AND state.country_id = cnt.country_id
   AND state.source_system = 'SA_INT_SALES'
LEFT JOIN bl_3nf.ce_cities cit 
    ON cit.city_name_src_id = stg.CITY_INT 
   AND cit.state_id = state.state_id
   AND cit.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_orders bl_3nf 
    WHERE bl_3nf.transaction_id = stg.ORDER_ID_INT 
      AND bl_3nf.source_system = 'SA_INT_SALES'
);
COMMIT;


-- CE_ORDERS: United States (Fixed: Grain changed to subchannel_id and city_id; mapped lineage and order_src_id)
BEGIN;
INSERT INTO bl_3nf.ce_orders (
    order_id, order_dt, order_status, returned, customer_id, sales_rep_id, 
    product_id, subchannel_id, city_id, payment_method, unit_price, quantity, 
    discount_percent, discount_amount, shipping_cost, tax_amount, order_amount, 
    cost_amount, profit_margin_percent, profit_amount, transaction_id, 
    source_system, source_entity, order_src_id, insert_dt, update_dt
)
SELECT 
    nextval('bl_3nf.seq_orders_id'),
    COALESCE(TO_DATE(stg.ORDER_DT, 'YYYY-MM-DD'), '1900-01-01'::DATE),
    COALESCE(stg.ORDER_STATUS, 'n. a.'),
    COALESCE(stg.RETURNED, 'n. a.'),
    COALESCE(cust.customer_id, -1),
    COALESCE(emp.sales_rep_id, -1),
    COALESCE(prod.product_id, -1),
    COALESCE(sub.subchannel_id, -1),
    COALESCE(cit.city_id, -1),
    COALESCE(stg.PAYMENT_METHOD, 'n. a.'),
    COALESCE(NULLIF(stg.UNIT_PRICE, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.QUANTITY, '')::BIGINT, 0),
    COALESCE(NULLIF(stg.DISCOUNT_PERCENT, '')::BIGINT, 0),
    COALESCE(NULLIF(stg.DISCOUNT_AMOUNT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.SHIPPING_COST, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.TAX_AMOUNT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.ORDER_AMOUNT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.COST_AMOUNT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.PROFIT_MARGIN_PERCENT, '')::NUMERIC(10,2), 0.00),
    COALESCE(NULLIF(stg.PROFIT_MARGIN_AMOUNT, '')::NUMERIC(10,2), 0.00),
    stg.ORDER_ID,
    'SA_US_SALES',
    'SRC_US_SALES',
    stg.ORDER_ID,
    CURRENT_DATE,
    CURRENT_DATE
FROM sa_us_sales.src_us_sales stg
LEFT JOIN bl_3nf.ce_customers_scd cust 
    ON cust.customer_src_id = stg.CUSTOMER_ID 
   AND cust.source_system = 'SA_US_SALES' 
   AND cust.is_active = 'Y'
LEFT JOIN bl_3nf.ce_employees emp 
    ON emp.sales_rep_src_id = stg.SALES_REP_ID 
   AND emp.source_system = 'SA_US_SALES'
LEFT JOIN bl_3nf.ce_products prod 
    ON prod.product_src_id = stg.PRODUCT_ID 
   AND prod.source_system = 'SA_US_SALES'
LEFT JOIN bl_3nf.ce_subchannels sub 
    ON sub.subchannel_src_id = stg.SUBCHANNEL 
   AND sub.source_system = 'SA_US_SALES'
LEFT JOIN bl_3nf.ce_countries cnt 
    ON cnt.country_name_src_id = 'US'
   AND cnt.source_system = 'SA_US_SALES'
LEFT JOIN bl_3nf.ce_states state
    ON state.state_name_src_id = stg.STATE
   AND state.country_id = cnt.country_id
   AND state.source_system = 'SA_US_SALES'
LEFT JOIN bl_3nf.ce_cities cit 
    ON cit.city_name_src_id = stg.CITY 
   AND cit.state_id = state.state_id
   AND cit.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1 FROM bl_3nf.ce_orders bl_3nf 
    WHERE bl_3nf.transaction_id = stg.ORDER_ID
      AND bl_3nf.source_system = 'SA_US_SALES'
);
COMMIT;


