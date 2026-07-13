
--CE_CATEGORIES(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
    FROM sa_int_sales.src_int_sales
    WHERE category IS NOT NULL
)
UPDATE bl_3nf.ce_categories tgt
SET
    product_category_name = src.category_name,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.product_category_name_src_id = src.category_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND tgt.product_category_name IS DISTINCT FROM src.category_name;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_src_id
    FROM sa_int_sales.src_int_sales
    WHERE category IS NOT NULL
)
INSERT INTO bl_3nf.ce_categories (
    product_category_id,
    product_category_name,
    source_system,
    source_entity,
    product_category_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_categories_id'),
    src.category_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.category_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_categories tgt
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_CATEGORIES(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_category IS NOT NULL
)
UPDATE bl_3nf.ce_categories tgt
SET
    product_category_name = src.category_name,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.product_category_name_src_id = src.category_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND tgt.product_category_name IS DISTINCT FROM src.category_name;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_category IS NOT NULL
)
INSERT INTO bl_3nf.ce_categories (
    product_category_id,
    product_category_name,
    source_system,
    source_entity,
    product_category_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_categories_id'),
    src.category_name,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.category_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_categories tgt
    WHERE tgt.product_category_name_src_id = src.category_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_COUNTRIES(INT)
BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(country, ''), 'n. a.') AS country_name,
        COALESCE(NULLIF(country, ''), 'n. a.') AS country_src_id
    FROM sa_int_sales.src_int_sales
    WHERE country IS NOT NULL
)
UPDATE bl_3nf.ce_countries tgt
SET
    country_name = src.country_name,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.country_name_src_id = src.country_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND tgt.country_name IS DISTINCT FROM src.country_name;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(country, ''), 'n. a.') AS country_name,
        COALESCE(NULLIF(country, ''), 'n. a.') AS country_src_id
    FROM sa_int_sales.src_int_sales
    WHERE country IS NOT NULL
)
INSERT INTO bl_3nf.ce_countries (
    country_id,
    country_name,
    source_system,
    source_entity,
    country_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_countries_id'),
    src.country_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.country_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_countries tgt
    WHERE tgt.country_name_src_id = src.country_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_COUNTRIES(US)

BEGIN;

INSERT INTO bl_3nf.ce_countries (
    country_id,
    country_name,
    source_system,
    source_entity,
    country_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_countries_id'),
    'US',
    'SA_US_SALES',
    'SRC_US_SALES',
    'US',
    CURRENT_DATE,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_countries tgt
    WHERE tgt.country_name_src_id = 'US'
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_CHANNELS(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE channel IS NOT NULL
)
UPDATE bl_3nf.ce_channels tgt
SET
    channel = src.channel_name,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.channel_src_id = src.channel_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND tgt.channel IS DISTINCT FROM src.channel_name;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE channel IS NOT NULL
)
INSERT INTO bl_3nf.ce_channels (
    channel_id,
    channel,
    source_system,
    source_entity,
    channel_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_channels_id'),
    src.channel_name,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.channel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_channels tgt
    WHERE tgt.channel_src_id = src.channel_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_CHANNELS(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE channel IS NOT NULL
)
UPDATE bl_3nf.ce_channels tgt
SET
    channel = src.channel_name,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.channel_src_id = src.channel_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND tgt.channel IS DISTINCT FROM src.channel_name;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE channel IS NOT NULL
)
INSERT INTO bl_3nf.ce_channels (
    channel_id,
    channel,
    source_system,
    source_entity,
    channel_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_channels_id'),
    src.channel_name,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.channel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_channels tgt
    WHERE tgt.channel_src_id = src.channel_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_EMPLOYEES(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(SALES_REP_ID_INT, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME_INT, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME_INT, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL_INT, ''), 'n. a.') AS email
    FROM sa_int_sales.src_int_sales
    WHERE SALES_REP_ID_INT IS NOT NULL
)
UPDATE bl_3nf.ce_employees tgt
SET
    sales_rep_first_name = src.first_name,
    sales_rep_last_name = src.last_name,
    sales_rep_email = src.email,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.sales_rep_src_id = src.rep_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND (
        tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
     OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
     OR tgt.sales_rep_email      IS DISTINCT FROM src.email
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(SALES_REP_ID_INT, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME_INT, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME_INT, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL_INT, ''), 'n. a.') AS email
    FROM sa_int_sales.src_int_sales
    WHERE SALES_REP_ID_INT IS NOT NULL
)
INSERT INTO bl_3nf.ce_employees (
    sales_rep_id,
    sales_rep_first_name,
    sales_rep_last_name,
    sales_rep_email,
    source_system,
    source_entity,
    sales_rep_src_id,
    insert_dt,
    update_dt
)
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
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees tgt
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_EMPLOYEES(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(SALES_REP_ID, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL, ''), 'n. a.') AS email
    FROM sa_us_sales.src_us_sales
    WHERE SALES_REP_ID IS NOT NULL
)
UPDATE bl_3nf.ce_employees tgt
SET
    sales_rep_first_name = src.first_name,
    sales_rep_last_name = src.last_name,
    sales_rep_email = src.email,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.sales_rep_src_id = src.rep_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
        tgt.sales_rep_first_name IS DISTINCT FROM src.first_name
     OR tgt.sales_rep_last_name  IS DISTINCT FROM src.last_name
     OR tgt.sales_rep_email      IS DISTINCT FROM src.email
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(SALES_REP_ID, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(SALES_REP_FIRST_NAME, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(SALES_REP_LAST_NAME, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(SALES_REP_EMAIL, ''), 'n. a.') AS email
    FROM sa_us_sales.src_us_sales
    WHERE SALES_REP_ID IS NOT NULL
)
INSERT INTO bl_3nf.ce_employees (
    sales_rep_id,
    sales_rep_first_name,
    sales_rep_last_name,
    sales_rep_email,
    source_system,
    source_entity,
    sales_rep_src_id,
    insert_dt,
    update_dt
)
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
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees tgt
    WHERE tgt.sales_rep_src_id = src.rep_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_SUBCATEGORIES(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
        COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subcategory IS NOT NULL
)
UPDATE bl_3nf.ce_subcategories tgt
SET
    product_subcategory_name = src.subcategory_name,
    product_category_id = cat.product_category_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_categories cat
    ON cat.product_category_name_src_id = src.category_name
   AND cat.source_system = 'SA_INT_SALES'
WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND (
       tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
    OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_name,
        COALESCE(NULLIF(subcategory, ''), 'n. a.') AS subcategory_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subcategory IS NOT NULL
)
INSERT INTO bl_3nf.ce_subcategories (
    product_subcategory_id,
    product_subcategory_name,
    product_category_id,
    source_system,
    source_entity,
    product_subcategory_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_subcategories_id'),
    src.subcategory_name,
    cat.product_category_id,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.subcategory_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_categories cat
    ON cat.product_category_name_src_id = src.category_name
   AND cat.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_subcategories tgt
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_SUBCATEGORIES(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_subcategory IS NOT NULL
)
UPDATE bl_3nf.ce_subcategories tgt
SET
    product_subcategory_name = src.subcategory_name,
    product_category_id = cat.product_category_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_categories cat
    ON cat.product_category_name_src_id = src.category_name
   AND cat.source_system = 'SA_US_SALES'
WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
       tgt.product_subcategory_name IS DISTINCT FROM src.subcategory_name
    OR tgt.product_category_id IS DISTINCT FROM cat.product_category_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_category, ''), 'n. a.') AS category_name,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_src_id
    FROM sa_us_sales.src_us_sales
    WHERE product_subcategory IS NOT NULL
)
INSERT INTO bl_3nf.ce_subcategories (
    product_subcategory_id,
    product_subcategory_name,
    product_category_id,
    source_system,
    source_entity,
    product_subcategory_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_subcategories_id'),
    src.subcategory_name,
    cat.product_category_id,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.subcategory_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_categories cat
    ON cat.product_category_name_src_id = src.category_name
   AND cat.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_subcategories tgt
    WHERE tgt.product_subcategory_name_src_id = src.subcategory_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_STATES(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
    FROM sa_us_sales.src_us_sales
    WHERE state IS NOT NULL
)
UPDATE bl_3nf.ce_states tgt
SET
    state_name = src.state_name,
    country_id = cnt.country_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_countries cnt
    ON cnt.country_name_src_id = 'US'
   AND cnt.source_system = 'SA_US_SALES'
WHERE tgt.state_name_src_id = src.state_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
        tgt.state_name IS DISTINCT FROM src.state_name
     OR tgt.country_id IS DISTINCT FROM cnt.country_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_src_id
    FROM sa_us_sales.src_us_sales
    WHERE state IS NOT NULL
)
INSERT INTO bl_3nf.ce_states (
    state_id,
    state_name,
    country_id,
    source_system,
    source_entity,
    state_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_states_id'),
    src.state_name,
    cnt.country_id,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.state_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_countries cnt
    ON cnt.country_name_src_id = 'US'
   AND cnt.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_states tgt
    WHERE tgt.state_name_src_id = src.state_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_PRODUCTS(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_id_int, ''), 'n. a.')       AS product_src_id,
        COALESCE(NULLIF(subcategory, ''), 'n. a.')      AS subcategory_name
    FROM sa_int_sales.src_int_sales
    WHERE product_id_int IS NOT NULL
)
UPDATE bl_3nf.ce_products tgt
SET
    product_subcategory_id = sub.product_subcategory_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_subcategories sub
    ON sub.product_subcategory_name_src_id = src.subcategory_name
   AND sub.source_system = 'SA_INT_SALES'
WHERE tgt.product_src_id = src.product_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_id_int, ''), 'n. a.')       AS product_src_id,
        COALESCE(NULLIF(subcategory, ''), 'n. a.')      AS subcategory_name
    FROM sa_int_sales.src_int_sales
    WHERE product_id_int IS NOT NULL
)
INSERT INTO bl_3nf.ce_products (
    product_id,
    product_subcategory_id,
    source_system,
    source_entity,
    product_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_products_id'),
    sub.product_subcategory_id,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.product_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_subcategories sub
    ON sub.product_subcategory_name_src_id = src.subcategory_name
   AND sub.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products tgt
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_PRODUCTS(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
    FROM sa_us_sales.src_us_sales
    WHERE product_id IS NOT NULL
)
UPDATE bl_3nf.ce_products tgt
SET
    product_subcategory_id = sub.product_subcategory_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_subcategories sub
    ON sub.product_subcategory_name_src_id = src.subcategory_name
   AND sub.source_system = 'SA_US_SALES'
WHERE tgt.product_src_id = src.product_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND tgt.product_subcategory_id IS DISTINCT FROM sub.product_subcategory_id;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(product_id, ''), 'n. a.')          AS product_src_id,
        COALESCE(NULLIF(product_subcategory, ''), 'n. a.') AS subcategory_name
    FROM sa_us_sales.src_us_sales
    WHERE product_id IS NOT NULL
)
INSERT INTO bl_3nf.ce_products (
    product_id,
    product_subcategory_id,
    source_system,
    source_entity,
    product_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_products_id'),
    sub.product_subcategory_id,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.product_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_subcategories sub
    ON sub.product_subcategory_name_src_id = src.subcategory_name
   AND sub.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products tgt
    WHERE tgt.product_src_id = src.product_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_CITIES(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_name,
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_src_id
    FROM sa_int_sales.src_int_sales
    WHERE city_int IS NOT NULL
)
UPDATE bl_3nf.ce_cities tgt
SET
    city_name = src.city_name,
    state_id = -1, 
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.city_name_src_id = src.city_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND (
        tgt.city_name IS DISTINCT FROM src.city_name
     OR tgt.state_id IS DISTINCT FROM -1
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_name,
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_src_id
    FROM sa_int_sales.src_int_sales
    WHERE city_int IS NOT NULL
)
INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_name,
    state_id,
    source_system,
    source_entity,
    city_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_cities_id'),
    src.city_name,
    -1, 
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.city_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities tgt
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_CITIES(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_name,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_src_id
    FROM sa_us_sales.src_us_sales
    WHERE city IS NOT NULL
)
UPDATE bl_3nf.ce_cities tgt
SET
    city_name = src.city_name,
    state_id = st.state_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_states st
    ON st.state_name_src_id = src.state_name
   AND st.source_system = 'SA_US_SALES'
WHERE tgt.city_name_src_id = src.city_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
        tgt.city_name IS DISTINCT FROM src.city_name
     OR tgt.state_id IS DISTINCT FROM st.state_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(state, ''), 'n. a.') AS state_name,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_name,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_src_id
    FROM sa_us_sales.src_us_sales
    WHERE city IS NOT NULL
)
INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_name,
    state_id,
    source_system,
    source_entity,
    city_name_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_cities_id'),
    src.city_name,
    st.state_id,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.city_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_states st
    ON st.state_name_src_id = src.state_name
   AND st.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities tgt
    WHERE tgt.city_name_src_id = src.city_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_SUBCHANNELS(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subchannel IS NOT NULL
)
UPDATE bl_3nf.ce_subchannels tgt
SET
    subchannel = src.subchannel_name,
    channel_id = ch.channel_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_channels ch
    ON ch.channel_src_id = src.channel_name
   AND ch.source_system = 'SA_INT_SALES'
WHERE tgt.subchannel_src_id = src.subchannel_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND (
        tgt.subchannel IS DISTINCT FROM src.subchannel_name
     OR tgt.channel_id IS DISTINCT FROM ch.channel_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
    FROM sa_int_sales.src_int_sales
    WHERE subchannel IS NOT NULL
)
INSERT INTO bl_3nf.ce_subchannels (
    subchannel_id,
    subchannel,
    channel_id,
    source_system,
    source_entity,
    subchannel_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_subchannels_id'),
    src.subchannel_name,
    ch.channel_id,
    'SA_INT_SALES',
    'SRC_INT_SALES',
    src.subchannel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_channels ch
    ON ch.channel_src_id = src.channel_name
   AND ch.source_system = 'SA_INT_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_subchannels tgt
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;

--CE_SUBCHANNELS(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE subchannel IS NOT NULL
)
UPDATE bl_3nf.ce_subchannels tgt
SET
    subchannel = src.subchannel_name,
    channel_id = ch.channel_id,
    update_dt = CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_channels ch
    ON ch.channel_src_id = src.channel_name
   AND ch.source_system = 'SA_US_SALES'
WHERE tgt.subchannel_src_id = src.subchannel_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
        tgt.subchannel IS DISTINCT FROM src.subchannel_name
     OR tgt.channel_id IS DISTINCT FROM ch.channel_id
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(channel, ''), 'n. a.') AS channel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_name,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id
    FROM sa_us_sales.src_us_sales
    WHERE subchannel IS NOT NULL
)
INSERT INTO bl_3nf.ce_subchannels (
    subchannel_id,
    subchannel,
    channel_id,
    source_system,
    source_entity,
    subchannel_src_id,
    insert_dt,
    update_dt
)
SELECT
    nextval('bl_3nf.seq_subchannels_id'),
    src.subchannel_name,
    ch.channel_id,
    'SA_US_SALES',
    'SRC_US_SALES',
    src.subchannel_src_id,
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
JOIN bl_3nf.ce_channels ch
    ON ch.channel_src_id = src.channel_name
   AND ch.source_system = 'SA_US_SALES'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_subchannels tgt
    WHERE tgt.subchannel_src_id = src.subchannel_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_CUSTOMERS_SCD(INT)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(CUSTOMER_ID_INT, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME_INT, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME_INT, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL_INT, ''), 'n. a.') AS email,
        'n. a.' AS age,
        'n. a.' AS gender,
        'n. a.' AS segment
    FROM sa_int_sales.src_int_sales
    WHERE CUSTOMER_ID_INT IS NOT NULL
)
UPDATE bl_3nf.ce_customers_scd tgt
SET
    is_active = 'N',
    end_dt = CURRENT_DATE - 1,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.customer_src_id = src.customer_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND tgt.is_active = 'Y'
  AND (
        tgt.customer_first_name IS DISTINCT FROM src.first_name
     OR tgt.customer_last_name  IS DISTINCT FROM src.last_name
     OR tgt.customer_email      IS DISTINCT FROM src.email
     OR tgt.customer_age        IS DISTINCT FROM src.age
     OR tgt.customer_gender     IS DISTINCT FROM src.gender
     OR tgt.customer_segment    IS DISTINCT FROM src.segment
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(CUSTOMER_ID_INT, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME_INT, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME_INT, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL_INT, ''), 'n. a.') AS email,
        'n. a.' AS age,
        'n. a.' AS gender,
        'n. a.' AS segment
    FROM sa_int_sales.src_int_sales
    WHERE CUSTOMER_ID_INT IS NOT NULL
)
INSERT INTO bl_3nf.ce_customers_scd (
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_age,
    customer_gender,
    customer_segment,
    source_system,
    source_entity,
    customer_src_id,
    is_active,
    start_dt,
    end_dt,
    insert_dt,
    update_dt
)
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
    src.customer_src_id,
    'Y',
    CURRENT_DATE,
    DATE '9999-12-31',
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers_scd tgt
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.source_system = 'SA_INT_SALES'
      AND tgt.is_active = 'Y'
);

COMMIT;

--CE_CUSTOMERS_SCD(US)

BEGIN;

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(CUSTOMER_ID, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL, ''), 'n. a.') AS email,
        COALESCE(NULLIF(CUSTOMER_AGE, ''), 'n. a.') AS age,
        COALESCE(NULLIF(CUSTOMER_GENDER, ''), 'n. a.') AS gender,
        COALESCE(NULLIF(CUSTOMER_SEGMENT, ''), 'n. a.') AS segment
    FROM sa_us_sales.src_us_sales
    WHERE CUSTOMER_ID IS NOT NULL
)
UPDATE bl_3nf.ce_customers_scd tgt
SET
    is_active = 'N',
    end_dt = CURRENT_DATE - 1,
    update_dt = CURRENT_DATE
FROM source_data src
WHERE tgt.customer_src_id = src.customer_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND tgt.is_active = 'Y'
  AND (
        tgt.customer_first_name IS DISTINCT FROM src.first_name
     OR tgt.customer_last_name  IS DISTINCT FROM src.last_name
     OR tgt.customer_email      IS DISTINCT FROM src.email
     OR tgt.customer_age        IS DISTINCT FROM src.age
     OR tgt.customer_gender     IS DISTINCT FROM src.gender
     OR tgt.customer_segment    IS DISTINCT FROM src.segment
  );

WITH source_data AS (
    SELECT DISTINCT
        COALESCE(NULLIF(CUSTOMER_ID, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(CUSTOMER_FIRST_NAME, ''), 'n. a.') AS first_name,
        COALESCE(NULLIF(CUSTOMER_LAST_NAME, ''), 'n. a.') AS last_name,
        COALESCE(NULLIF(CUSTOMER_EMAIL, ''), 'n. a.') AS email,
        COALESCE(NULLIF(CUSTOMER_AGE, ''), 'n. a.') AS age,
        COALESCE(NULLIF(CUSTOMER_GENDER, ''), 'n. a.') AS gender,
        COALESCE(NULLIF(CUSTOMER_SEGMENT, ''), 'n. a.') AS segment
    FROM sa_us_sales.src_us_sales
    WHERE CUSTOMER_ID IS NOT NULL
)
INSERT INTO bl_3nf.ce_customers_scd (
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_email,
    customer_age,
    customer_gender,
    customer_segment,
    source_system,
    source_entity,
    customer_src_id,
    is_active,
    start_dt,
    end_dt,
    insert_dt,
    update_dt
)
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
    src.customer_src_id,
    'Y',
    CURRENT_DATE,
    DATE '9999-12-31',
    CURRENT_DATE,
    CURRENT_DATE
FROM source_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers_scd tgt
    WHERE tgt.customer_src_id = src.customer_src_id
      AND tgt.source_system = 'SA_US_SALES'
      AND tgt.is_active = 'Y'
);

COMMIT;

--CE_ORDERS(US)

BEGIN;

WITH incoming_data AS (
    SELECT 
        COALESCE(NULLIF(order_id, ''), 'n. a.') AS order_src_id,
        CAST(COALESCE(NULLIF(order_dt, ''), '1900-01-01') AS DATE) AS order_dt,
        COALESCE(NULLIF(order_status, ''), 'n. a.') AS order_status,
        COALESCE(NULLIF(returned, ''), 'n. a.') AS returned,
        COALESCE(NULLIF(customer_id, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(sales_rep_id, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(product_id, ''), 'n. a.') AS product_src_id,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_src_id,
        COALESCE(NULLIF(payment_method, ''), 'n. a.') AS payment_method,
        CAST(COALESCE(NULLIF(unit_price, ''), '0') AS NUMERIC(10,2)) AS unit_price,
        CAST(COALESCE(NULLIF(quantity, ''), '0') AS BIGINT) AS quantity,
        CAST(COALESCE(NULLIF(discount_percent, ''), '0') AS BIGINT) AS discount_percent,
        CAST(COALESCE(NULLIF(discount_amount, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
        CAST(COALESCE(NULLIF(shipping_cost, ''), '0') AS NUMERIC(10,2)) AS shipping_cost,
        CAST(COALESCE(NULLIF(tax_amount, ''), '0') AS NUMERIC(10,2)) AS tax_amount,
        CAST(COALESCE(NULLIF(order_amount, ''), '0') AS NUMERIC(10,2)) AS order_amount,
        CAST(COALESCE(NULLIF(cost_amount, ''), '0') AS NUMERIC(10,2)) AS cost_amount,
        CAST(COALESCE(NULLIF(profit_margin_percent, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
        CAST(COALESCE(NULLIF(profit_margin_amount, ''), '0') AS NUMERIC(10,2)) AS profit_margin_amount,
        COALESCE(NULLIF(order_id, ''), 'n. a.') AS transaction_id
    FROM sa_us_sales.src_us_sales
    WHERE order_id IS NOT NULL
),
mapped_data AS (
    SELECT
        src.*,
        COALESCE(cust.customer_id, -1) AS customer_id,
        COALESCE(e.sales_rep_id, -1) AS sales_rep_id,
        COALESCE(p.product_id, -1) AS product_id,
        COALESCE(s.subchannel_id, -1) AS subchannel_id,
        COALESCE(c.city_id, -1) AS city_id
    FROM incoming_data src
    LEFT JOIN bl_3nf.ce_customers_scd cust 
        ON cust.customer_src_id = src.customer_src_id 
       AND cust.source_system = 'SA_US_SALES'
       AND src.order_dt BETWEEN cust.start_dt AND cust.end_dt
    LEFT JOIN bl_3nf.ce_employees e 
        ON e.sales_rep_src_id = src.rep_src_id AND e.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_products p 
        ON p.product_src_id = src.product_src_id AND p.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_subchannels s 
        ON s.subchannel_src_id = src.subchannel_src_id AND s.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_cities c 
        ON c.city_name_src_id = src.city_src_id AND c.source_system = 'SA_US_SALES'
)
UPDATE bl_3nf.ce_orders tgt
SET
    order_dt = src.order_dt,
    order_status = src.order_status,
    returned = src.returned,
    customer_id = src.customer_id,
    sales_rep_id = src.sales_rep_id,
    product_id = src.product_id,
    subchannel_id = src.subchannel_id,
    city_id = src.city_id,
    payment_method = src.payment_method,
    unit_price = src.unit_price,
    quantity = src.quantity,
    discount_percent = src.discount_percent,
    discount_amount = src.discount_amount,
    shipping_cost = src.shipping_cost,
    tax_amount = src.tax_amount,
    order_amount = src.order_amount,
    cost_amount = src.cost_amount,
    profit_margin_percent = src.profit_margin_percent,
    profit_amount = src.profit_margin_amount,
    transaction_id = src.order_src_id,
    update_dt = CURRENT_DATE
FROM mapped_data src
WHERE tgt.order_src_id = src.order_src_id
  AND tgt.source_system = 'SA_US_SALES'
  AND (
        tgt.order_dt IS DISTINCT FROM src.order_dt
     OR tgt.order_status IS DISTINCT FROM src.order_status
     OR tgt.returned IS DISTINCT FROM src.returned
     OR tgt.customer_id IS DISTINCT FROM src.customer_id
     OR tgt.sales_rep_id IS DISTINCT FROM src.sales_rep_id
     OR tgt.product_id IS DISTINCT FROM src.product_id
     OR tgt.subchannel_id IS DISTINCT FROM src.subchannel_id
     OR tgt.city_id IS DISTINCT FROM src.city_id
     OR tgt.payment_method IS DISTINCT FROM src.payment_method
     OR tgt.unit_price IS DISTINCT FROM src.unit_price
     OR tgt.quantity IS DISTINCT FROM src.quantity
     OR tgt.discount_percent IS DISTINCT FROM src.discount_percent
     OR tgt.discount_amount IS DISTINCT FROM src.discount_amount
     OR tgt.shipping_cost IS DISTINCT FROM src.shipping_cost
     OR tgt.tax_amount IS DISTINCT FROM src.tax_amount
     OR tgt.order_amount IS DISTINCT FROM src.order_amount
     OR tgt.cost_amount IS DISTINCT FROM src.cost_amount
     OR tgt.profit_margin_percent IS DISTINCT FROM src.profit_margin_percent
     OR tgt.profit_amount IS DISTINCT FROM src.profit_margin_amount
     OR tgt.transaction_id IS DISTINCT FROM src.order_src_id
  );

WITH incoming_data AS (
    SELECT 
        COALESCE(NULLIF(order_id, ''), 'n. a.') AS order_src_id,
        CAST(COALESCE(NULLIF(order_dt, ''), '1900-01-01') AS DATE) AS order_dt,
        COALESCE(NULLIF(order_status, ''), 'n. a.') AS order_status,
        COALESCE(NULLIF(returned, ''), 'n. a.') AS returned,
        COALESCE(NULLIF(customer_id, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(sales_rep_id, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(product_id, ''), 'n. a.') AS product_src_id,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id,
        COALESCE(NULLIF(city, ''), 'n. a.') AS city_src_id,
        COALESCE(NULLIF(payment_method, ''), 'n. a.') AS payment_method,
        CAST(COALESCE(NULLIF(unit_price, ''), '0') AS NUMERIC(10,2)) AS unit_price,
        CAST(COALESCE(NULLIF(quantity, ''), '0') AS BIGINT) AS quantity,
        CAST(COALESCE(NULLIF(discount_percent, ''), '0') AS BIGINT) AS discount_percent,
        CAST(COALESCE(NULLIF(discount_amount, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
        CAST(COALESCE(NULLIF(shipping_cost, ''), '0') AS NUMERIC(10,2)) AS shipping_cost,
        CAST(COALESCE(NULLIF(tax_amount, ''), '0') AS NUMERIC(10,2)) AS tax_amount,
        CAST(COALESCE(NULLIF(order_amount, ''), '0') AS NUMERIC(10,2)) AS order_amount,
        CAST(COALESCE(NULLIF(cost_amount, ''), '0') AS NUMERIC(10,2)) AS cost_amount,
        CAST(COALESCE(NULLIF(profit_margin_percent, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
        CAST(COALESCE(NULLIF(profit_MARGIN_amount, ''), '0') AS NUMERIC(10,2)) AS profit_amount,
        COALESCE(NULLIF(ORDER_id, ''), 'n. a.') AS transaction_id
    FROM sa_us_sales.src_us_sales
    WHERE order_id IS NOT NULL
),
mapped_data AS (
    SELECT
        src.*,
        COALESCE(cust.customer_id, -1) AS customer_id,
        COALESCE(e.sales_rep_id, -1) AS sales_rep_id,
        COALESCE(p.product_id, -1) AS product_id,
        COALESCE(s.subchannel_id, -1) AS subchannel_id,
        COALESCE(c.city_id, -1) AS city_id
    FROM incoming_data src
    LEFT JOIN bl_3nf.ce_customers_scd cust 
        ON cust.customer_src_id = src.customer_src_id 
       AND cust.source_system = 'SA_US_SALES'
       AND src.order_dt BETWEEN cust.start_dt AND cust.end_dt
    LEFT JOIN bl_3nf.ce_employees e 
        ON e.sales_rep_src_id = src.rep_src_id AND e.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_products p 
        ON p.product_src_id = src.product_src_id AND p.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_subchannels s 
        ON s.subchannel_src_id = src.subchannel_src_id AND s.source_system = 'SA_US_SALES'
    LEFT JOIN bl_3nf.ce_cities c 
        ON c.city_name_src_id = src.city_src_id AND c.source_system = 'SA_US_SALES'
)
INSERT INTO bl_3nf.ce_orders (
    order_id, order_dt, order_status, returned, customer_id, sales_rep_id, product_id,
    subchannel_id, city_id, payment_method, unit_price, quantity, discount_percent,
    discount_amount, shipping_cost, tax_amount, order_amount, cost_amount,
    profit_margin_percent, profit_amount, transaction_id, source_system, source_entity,
    order_src_id, insert_dt, update_dt
)
SELECT
    nextval('bl_3nf.seq_orders_id'),
    src.order_dt, src.order_status, src.returned, src.customer_id, src.sales_rep_id, src.product_id,
    src.subchannel_id, src.city_id, src.payment_method, src.unit_price, src.quantity, src.discount_percent,
    src.discount_amount, src.shipping_cost, src.tax_amount, src.order_amount, src.cost_amount,
    src.profit_margin_percent, src.profit_amount, src.order_src_id, 'SA_US_SALES', 'SRC_US_SALES',
    src.order_src_id, CURRENT_DATE, CURRENT_DATE
FROM mapped_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_orders tgt
    WHERE tgt.order_src_id = src.order_src_id
      AND tgt.source_system = 'SA_US_SALES'
);

COMMIT;

--CE_ORDERS(INT)

BEGIN;

WITH incoming_data AS (
    SELECT 
        COALESCE(NULLIF(order_id_int, ''), 'n. a.') AS order_src_id,
        CAST(COALESCE(NULLIF(order_dt_int, ''), '1900-01-01') AS DATE) AS order_dt,
        COALESCE(NULLIF(order_status_int, ''), 'n. a.') AS order_status,
        COALESCE(NULLIF(returned, ''), 'n. a.') AS returned,
        COALESCE(NULLIF(customer_id_int, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id,
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_src_id,
        COALESCE(NULLIF(payment, ''), 'n. a.') AS payment_method,
        CAST(COALESCE(NULLIF(price, ''), '0') AS NUMERIC(10,2)) AS unit_price,
        CAST(COALESCE(NULLIF(quantity_int, ''), '0') AS BIGINT) AS quantity,
        CAST(COALESCE(NULLIF(discount_percent_int, ''), '0') AS BIGINT) AS discount_percent,
        CAST(COALESCE(NULLIF(discount_amount_int, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
        CAST(COALESCE(NULLIF(shipping_cost_int, ''), '0') AS NUMERIC(10,2)) AS shipping_cost,
        CAST(COALESCE(NULLIF(tax, ''), '0') AS NUMERIC(10,2)) AS tax_amount,
        CAST(COALESCE(NULLIF(order_amount_int, ''), '0') AS NUMERIC(10,2)) AS order_amount,
        CAST(COALESCE(NULLIF(cost_amount_int, ''), '0') AS NUMERIC(10,2)) AS cost_amount,
        CAST(COALESCE(NULLIF(pprofit_margin_percent_int, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
        CAST(COALESCE(NULLIF(profit_amount_int, ''), '0') AS NUMERIC(10,2)) AS profit_amount,
        COALESCE(NULLIF(order_id_int, ''), 'n. a.') AS transaction_id
    FROM sa_int_sales.src_int_sales
    WHERE order_id_int IS NOT NULL
),
mapped_data AS (
    SELECT
        src.*,
        COALESCE(cust.customer_id, -1) AS customer_id,
        COALESCE(e.sales_rep_id, -1) AS sales_rep_id,
        COALESCE(p.product_id, -1) AS product_id,
        COALESCE(s.subchannel_id, -1) AS subchannel_id,
        COALESCE(c.city_id, -1) AS city_id
    FROM incoming_data src
    LEFT JOIN bl_3nf.ce_customers_scd cust 
        ON cust.customer_src_id = src.customer_src_id 
       AND cust.source_system = 'SA_INT_SALES'
       AND src.order_dt BETWEEN cust.start_dt AND cust.end_dt
    LEFT JOIN bl_3nf.ce_employees e 
        ON e.sales_rep_src_id = src.rep_src_id AND e.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_products p 
        ON p.product_src_id = src.product_src_id AND p.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_subchannels s 
        ON s.subchannel_src_id = src.subchannel_src_id AND s.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_cities c 
        ON c.city_name_src_id = src.city_src_id AND c.source_system = 'SA_INT_SALES'
)
UPDATE bl_3nf.ce_orders tgt
SET
    order_dt = src.order_dt,
    order_status = src.order_status,
    returned = src.returned,
    customer_id = src.customer_id,
    sales_rep_id = src.sales_rep_id,
    product_id = src.product_id,
    subchannel_id = src.subchannel_id,
    city_id = src.city_id,
    payment_method = src.payment_method,
    unit_price = src.unit_price,
    quantity = src.quantity,
    discount_percent = src.discount_percent,
    discount_amount = src.discount_amount,
    shipping_cost = src.shipping_cost,
    tax_amount = src.tax_amount,
    order_amount = src.order_amount,
    cost_amount = src.cost_amount,
    profit_margin_percent = src.profit_margin_percent,
    profit_amount = src.profit_amount,
    transaction_id = src.transaction_id,
    update_dt = CURRENT_DATE
FROM mapped_data src
WHERE tgt.order_src_id = src.order_src_id
  AND tgt.source_system = 'SA_INT_SALES'
  AND (
        tgt.order_dt IS DISTINCT FROM src.order_dt
     OR tgt.order_status IS DISTINCT FROM src.order_status
     OR tgt.returned IS DISTINCT FROM src.returned
     OR tgt.customer_id IS DISTINCT FROM src.customer_id
     OR tgt.sales_rep_id IS DISTINCT FROM src.sales_rep_id
     OR tgt.product_id IS DISTINCT FROM src.product_id
     OR tgt.subchannel_id IS DISTINCT FROM src.subchannel_id
     OR tgt.city_id IS DISTINCT FROM src.city_id
     OR tgt.payment_method IS DISTINCT FROM src.payment_method
     OR tgt.unit_price IS DISTINCT FROM src.unit_price
     OR tgt.quantity IS DISTINCT FROM src.quantity
     OR tgt.discount_percent IS DISTINCT FROM src.discount_percent
     OR tgt.discount_amount IS DISTINCT FROM src.discount_amount
     OR tgt.shipping_cost IS DISTINCT FROM src.shipping_cost
     OR tgt.tax_amount IS DISTINCT FROM src.tax_amount
     OR tgt.order_amount IS DISTINCT FROM src.order_amount
     OR tgt.cost_amount IS DISTINCT FROM src.cost_amount
     OR tgt.profit_margin_percent IS DISTINCT FROM src.profit_margin_percent
     OR tgt.profit_amount IS DISTINCT FROM src.profit_amount
     OR tgt.transaction_id IS DISTINCT FROM src.transaction_id
  );



WITH incoming_data AS (
    SELECT 
        COALESCE(NULLIF(order_id_int, ''), 'n. a.') AS order_src_id,
        CAST(COALESCE(NULLIF(order_dt_int, ''), '1900-01-01') AS DATE) AS order_dt,
        COALESCE(NULLIF(order_status_int, ''), 'n. a.') AS order_status,
        COALESCE(NULLIF(returned, ''), 'n. a.') AS returned,
        COALESCE(NULLIF(customer_id_int, ''), 'n. a.') AS customer_src_id,
        COALESCE(NULLIF(sales_rep_id_int, ''), 'n. a.') AS rep_src_id,
        COALESCE(NULLIF(product_id_int, ''), 'n. a.') AS product_src_id,
        COALESCE(NULLIF(subchannel, ''), 'n. a.') AS subchannel_src_id,
        COALESCE(NULLIF(city_int, ''), 'n. a.') AS city_src_id,
        COALESCE(NULLIF(payment, ''), 'n. a.') AS payment_method,
        CAST(COALESCE(NULLIF(price, ''), '0') AS NUMERIC(10,2)) AS unit_price,
        CAST(COALESCE(NULLIF(quantity_int, ''), '0') AS BIGINT) AS quantity,
        CAST(COALESCE(NULLIF(discount_percent_int, ''), '0') AS BIGINT) AS discount_percent,
        CAST(COALESCE(NULLIF(discount_amount_int, ''), '0') AS NUMERIC(10,2)) AS discount_amount,
        CAST(COALESCE(NULLIF(shipping_cost_int, ''), '0') AS NUMERIC(10,2)) AS shipping_cost,
        CAST(COALESCE(NULLIF(tax, ''), '0') AS NUMERIC(10,2)) AS tax_amount,
        CAST(COALESCE(NULLIF(order_amount_int, ''), '0') AS NUMERIC(10,2)) AS order_amount,
        CAST(COALESCE(NULLIF(cost_amount_int, ''), '0') AS NUMERIC(10,2)) AS cost_amount,
        CAST(COALESCE(NULLIF(pprofit_margin_percent_int, ''), '0') AS NUMERIC(10,2)) AS profit_margin_percent,
        CAST(COALESCE(NULLIF(profit_amount_int, ''), '0') AS NUMERIC(10,2)) AS profit_amount,
        COALESCE(NULLIF(order_id_int, ''), 'n. a.') AS transaction_id
    FROM sa_int_sales.src_int_sales
    WHERE order_id_int IS NOT NULL
),
mapped_data AS (
    SELECT
        src.*,
        COALESCE(cust.customer_id, -1) AS customer_id,
        COALESCE(e.sales_rep_id, -1) AS sales_rep_id,
        COALESCE(p.product_id, -1) AS product_id,
        COALESCE(s.subchannel_id, -1) AS subchannel_id,
        COALESCE(c.city_id, -1) AS city_id
    FROM incoming_data src
    LEFT JOIN bl_3nf.ce_customers_scd cust 
        ON cust.customer_src_id = src.customer_src_id 
       AND cust.source_system = 'SA_INT_SALES'
       AND src.order_dt BETWEEN cust.start_dt AND cust.end_dt
    LEFT JOIN bl_3nf.ce_employees e 
        ON e.sales_rep_src_id = src.rep_src_id AND e.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_products p 
        ON p.product_src_id = src.product_src_id AND p.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_subchannels s 
        ON s.subchannel_src_id = src.subchannel_src_id AND s.source_system = 'SA_INT_SALES'
    LEFT JOIN bl_3nf.ce_cities c 
        ON c.city_name_src_id = src.city_src_id AND c.source_system = 'SA_INT_SALES'
)
INSERT INTO bl_3nf.ce_orders (
    order_id, order_dt, order_status, returned, customer_id, sales_rep_id, product_id,
    subchannel_id, city_id, payment_method, unit_price, quantity, discount_percent,
    discount_amount, shipping_cost, tax_amount, order_amount, cost_amount,
    profit_margin_percent, profit_amount, transaction_id, source_system, source_entity,
    order_src_id, insert_dt, update_dt
)
SELECT
    nextval('bl_3nf.seq_orders_id'),
    src.order_dt, src.order_status, src.returned, src.customer_id, src.sales_rep_id, src.product_id,
    src.subchannel_id, src.city_id, src.payment_method, src.unit_price, src.quantity, src.discount_percent,
    src.discount_amount, src.shipping_cost, src.tax_amount, src.order_amount, src.cost_amount,
    src.profit_margin_percent, src.profit_amount, src.transaction_id, 'SA_INT_SALES', 'SRC_INT_SALES',
    src.order_src_id, CURRENT_DATE, CURRENT_DATE
FROM mapped_data src
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_orders tgt
    WHERE tgt.order_src_id = src.order_src_id
      AND tgt.source_system = 'SA_INT_SALES'
);

COMMIT;