

/*Please note that the task started with reconciliation checks rather than test execution.
 * Therefore, part of the test cases have already been covered by those checks. 
 * For example, verifying that the tables exist and are not empty.*/

-- Create reconciliation_results table
CREATE TABLE lnd.reconciliation_results (
    table_name VARCHAR(100),
    key_column VARCHAR(100),
    src_id VARCHAR(256),
    trg_id VARCHAR(256),
    reconciliation_status VARCHAR(255)
);

SELECT
    t.table_name,
    t.lnd_count,
    src_counts.src_count,
    (t.lnd_count - src_counts.src_count) AS difference
FROM (
    SELECT 's1_channels' AS table_name, COUNT(*) AS lnd_count FROM lnd.lnd_s1_channels
    UNION ALL
    SELECT 's1_clients', COUNT(*) FROM lnd.lnd_s1_clients
    UNION ALL
    SELECT 's1_products', COUNT(*) FROM lnd.lnd_s1_products
    UNION ALL
    SELECT 's1_sales', COUNT(*) FROM lnd.lnd_s1_sales
    UNION ALL
    SELECT 's2_channels', COUNT(*) FROM lnd.lnd_s2_channels
    UNION ALL
    SELECT 's2_client_sales', COUNT(*) FROM lnd.lnd_s2_client_sales
    UNION ALL
    SELECT 's2_clients', COUNT(*) FROM lnd.lnd_s2_clients
    UNION ALL
    SELECT 's2_locations', COUNT(*) FROM lnd.lnd_s2_locations
) t
JOIN (
    SELECT * FROM dblink(
        'dbname=dwh_src_hw_db user=postgres password=**** host=localhost',
        'SELECT
            ''s1_channels'', COUNT(*) FROM s1.s1_channels
         UNION ALL SELECT ''s1_clients'', COUNT(*) FROM s1.s1_clients
         UNION ALL SELECT ''s1_products'', COUNT(*) FROM s1.s1_products
         UNION ALL SELECT ''s1_sales'', COUNT(*) FROM s1.s1_sales
         UNION ALL SELECT ''s2_channels'', COUNT(*) FROM s2.s2_channels
         UNION ALL SELECT ''s2_client_sales'', COUNT(*) FROM s2.s2_client_sales
         UNION ALL SELECT ''s2_clients'', COUNT(*) FROM s2.s2_clients
         UNION ALL SELECT ''s2_locations'', COUNT(*) FROM s2.s2_locations'
    ) AS s(table_name TEXT, src_count BIGINT)
) src_counts ON t.table_name = src_counts.table_name
ORDER BY t.table_name;
-- s1_channels
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT
    's1_channels' AS table_name,
    'channel_id' AS key_column,
    src.channel_id AS src_id,
    trg.channel_id AS trg_id,
    CASE
        WHEN src.channel_id IS NULL THEN 'Only in target'
        WHEN trg.channel_id IS NULL THEN 'Only in source'
        WHEN src.channel_name <> trg.channel_name THEN 'Mismatch in channel_name'
        WHEN src.channel_location <> trg.channellocation THEN 'Mismatch in channel_location'
        ELSE 'Match'
    END AS reconciliation_status
FROM lnd.lnd_s1_channels trg
FULL OUTER JOIN (
    SELECT * FROM dblink(
        'dbname=dwh_src_hw_db
         user=postgres
         password=YOUR_PASSWORD
         host=localhost',
        'SELECT * FROM s1.s1_channels'
    ) AS src(channel_id VARCHAR(256), channel_name VARCHAR(256), channel_location VARCHAR(256))
) src
ON src.channel_id = trg.channel_id
WHERE
    CASE
        WHEN src.channel_id IS NULL THEN 'Only in target'
        WHEN trg.channel_id IS NULL THEN 'Only in source'
        WHEN src.channel_name <> trg.channel_name THEN 'Mismatch in channel_name'
        WHEN src.channel_location <> trg.channellocation THEN 'Mismatch in channel_location'
        ELSE 'Match'
    END <> 'Match';

-- s1_clients
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's1_clients', 'client_id', src.client_id, trg.client_id,
    CASE
        WHEN src.client_id IS NULL THEN 'Only in target'
        WHEN trg.client_id IS NULL THEN 'Only in source'
        WHEN src.first_name <> trg.first_name THEN 'Mismatch in first_name'
        WHEN src.middle_name <> trg.middle_name THEN 'Mismatch in middle_name'
        WHEN src.last_name <> trg.last_name THEN 'Mismatch in last_name'
        WHEN src.email <> trg.email THEN 'Mismatch in email'
        WHEN src.phone <> trg.phone THEN 'Mismatch in phone'
        WHEN src.first_purchase <> trg.first_purchase THEN 'Mismatch in first_purchase'
        ELSE 'Match'
    END
FROM lnd.lnd_s1_clients trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s1.s1_clients') AS src(client_id VARCHAR(256), first_name VARCHAR(256), middle_name VARCHAR(256),
        last_name VARCHAR(256), email VARCHAR(256), phone VARCHAR(256), first_purchase VARCHAR(256))
) src ON src.client_id = trg.client_id
WHERE trg.client_id IS NULL OR src.client_id IS NULL
   OR src.first_name <> trg.first_name OR src.middle_name <> trg.middle_name
   OR src.last_name <> trg.last_name OR src.email <> trg.email
   OR src.phone <> trg.phone OR src.first_purchase <> trg.first_purchase;

-- s1_sales (composite key)
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's1_sales', 'client_id+channel_id+sale_date+product_id',
    src.client_id||'-'||src.channel_id||'-'||src.sale_date||'-'||src.product_id,
    trg.client_id||'-'||trg.channel_id||'-'||trg.sale_date||'-'||trg.product_id,
    CASE
        WHEN src.client_id IS NULL THEN 'Only in target'
        WHEN trg.client_id IS NULL THEN 'Only in source'
        WHEN src.units <> trg.units THEN 'Mismatch in units'
        WHEN src.purchase_date IS DISTINCT FROM trg.purchase_date THEN 'Mismatch in purchase_date'
        ELSE 'Match'
    END
FROM lnd.lnd_s1_sales trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s1.s1_sales') AS src(client_id VARCHAR(256), channel_id VARCHAR(256), sale_date VARCHAR(256),
        units VARCHAR(256), product_id VARCHAR(256), purchase_date VARCHAR(256))
) src ON src.client_id = trg.client_id AND src.channel_id = trg.channel_id
      AND src.sale_date = trg.sale_date AND src.product_id = trg.product_id
WHERE trg.client_id IS NULL OR src.client_id IS NULL
   OR src.units <> trg.units OR src.purchase_date IS DISTINCT FROM trg.purchase_date;

-- s2_client_sales (composite key)
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's2_client_sales', 'client_id+channel_id+saled_at+product_id',
    src.client_id||'-'||src.channel_id||'-'||src.saled_at||'-'||src.product_id,
    trg.client_id||'-'||trg.channel_id||'-'||trg.saled_at||'-'||trg.product_id,
    CASE
        WHEN src.client_id IS NULL THEN 'Only in target'
        WHEN trg.client_id IS NULL THEN 'Only in source'
        WHEN src.product_name <> trg.product_name THEN 'Mismatch in product_name'
        WHEN src.product_price <> trg.product_price THEN 'Mismatch in product_price'
        WHEN src.product_amount <> trg.product_amount THEN 'Mismatch in product_amount'
        WHEN src.sold_date <> trg.sold_date THEN 'Mismatch in sold_date'
        ELSE 'Match'
    END
FROM lnd.lnd_s2_client_sales trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s2.s2_client_sales') AS src(client_id VARCHAR(256), channel_id VARCHAR(256), saled_at VARCHAR(256),
        product_id VARCHAR(256), product_name VARCHAR(256), product_price VARCHAR(256), product_amount VARCHAR(256), sold_date VARCHAR(256))
) src ON src.client_id = trg.client_id AND src.channel_id = trg.channel_id
      AND src.saled_at = trg.saled_at AND src.product_id = trg.product_id
WHERE trg.client_id IS NULL OR src.client_id IS NULL
   OR src.product_name <> trg.product_name OR src.product_price <> trg.product_price
   OR src.product_amount <> trg.product_amount OR src.sold_date <> trg.sold_date;

-- s2_locations
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's2_locations', 'location_id', src.location_id, trg.location_id,
    CASE
        WHEN src.location_id IS NULL THEN 'Only in target'
        WHEN trg.location_id IS NULL THEN 'Only in source'
        WHEN src.location_name <> trg.location_name THEN 'Mismatch in location_name'
        ELSE 'Match'
    END
FROM lnd.lnd_s2_locations trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s2.s2_locations') AS src(location_id VARCHAR(256), location_name VARCHAR(256))
) src ON src.location_id = trg.location_id
WHERE trg.location_id IS NULL OR src.location_id IS NULL OR src.location_name <> trg.location_name;

-- s1_products
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT
    's1_products', 'product_id', src.product_id, trg.product_id,
    CASE
        WHEN src.product_id IS NULL THEN 'Only in target'
        WHEN trg.product_id IS NULL THEN 'Only in source'
        WHEN src.product_name <> trg.product_name THEN 'Mismatch in product_name'
        WHEN src.cost <> trg.cost THEN 'Mismatch in cost'
        ELSE 'Match'
    END
FROM lnd.lnd_s1_products trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s1.s1_products') AS src(product_id VARCHAR(256), cost VARCHAR(256), product_name VARCHAR(256))
) src ON src.product_id = trg.product_id
WHERE
    trg.product_id IS NULL
    OR src.product_id IS NULL
    OR src.product_name <> trg.product_name
    OR src.cost <> trg.cost;

-- s2_channels
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's2_channels', 'channel_id', src.channel_id, trg.channel_id,
    CASE
        WHEN src.channel_id IS NULL THEN 'Only in target'
        WHEN trg.channel_id IS NULL THEN 'Only in source'
        WHEN src.channel_name <> trg.channel_name THEN 'Mismatch in channel_name'
        WHEN src.location_id <> trg.location_id THEN 'Mismatch in location_id'
        ELSE 'Match'
    END
FROM lnd.lnd_s2_channels trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s2.s2_channels') AS src(channel_id VARCHAR(256), channel_name VARCHAR(256), location_id VARCHAR(256))
) src ON src.channel_id = trg.channel_id
WHERE trg.channel_id IS NULL OR src.channel_id IS NULL
   OR src.channel_name <> trg.channel_name OR src.location_id <> trg.location_id;

-- s2_clients
INSERT INTO lnd.reconciliation_results (table_name, key_column, src_id, trg_id, reconciliation_status)
SELECT 's2_clients', 'client_id', src.client_id, trg.client_id,
    CASE
        WHEN src.client_id IS NULL THEN 'Only in target'
        WHEN trg.client_id IS NULL THEN 'Only in source'
        WHEN src.first_name <> trg.first_name THEN 'Mismatch in first_name'
        WHEN src.last_name <> trg.last_name THEN 'Mismatch in last_name'
        WHEN src.email <> trg.email THEN 'Mismatch in email'
        WHEN src.phone_code <> trg.phone_code THEN 'Mismatch in phone_code'
        WHEN src.phone_number <> trg.phone_number THEN 'Mismatch in phone_number'
        WHEN src.first_purchase <> trg.first_purchase THEN 'Mismatch in first_purchase'
        WHEN src.valid_from <> trg.valid_from THEN 'Mismatch in valid_from'
        WHEN src.valid_to <> trg.valid_to THEN 'Mismatch in valid_to'
        ELSE 'Match'
    END
FROM lnd.lnd_s2_clients trg
FULL OUTER JOIN (
    SELECT * FROM dblink('dbname=dwh_src_hw_db user=postgres password=YOUR_PASSWORD host=localhost',
        'SELECT * FROM s2.s2_clients') AS src(client_id VARCHAR(256), first_name VARCHAR(256), last_name VARCHAR(256),
        email VARCHAR(256), phone_code VARCHAR(256), phone_number VARCHAR(256), first_purchase VARCHAR(256),
        valid_from VARCHAR(256), valid_to VARCHAR(256))
) src ON src.client_id = trg.client_id
WHERE trg.client_id IS NULL OR src.client_id IS NULL
   OR src.first_name <> trg.first_name OR src.last_name <> trg.last_name
   OR src.email <> trg.email OR src.phone_code <> trg.phone_code
   OR src.phone_number <> trg.phone_number OR src.first_purchase <> trg.first_purchase
   OR src.valid_from <> trg.valid_from OR src.valid_to <> trg.valid_to;


SELECT * FROM lnd.reconciliation_results;

--s1_clients +11 count discrepancy analysis
SELECT client_id, COUNT(*) AS row_count
FROM lnd.lnd_s1_clients
GROUP BY client_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

--C909: Row counts match across Landing → DWH 
SELECT
    'dwh_clients' AS dwh_table,
    (SELECT COUNT(*) FROM dwh.dwh_clients) AS dwh_count,
    (SELECT COUNT(*) FROM lnd.lnd_s1_clients) + (SELECT COUNT(*) FROM lnd.lnd_s2_clients) AS lnd_combined
UNION ALL
SELECT
    'dwh_channels',
    (SELECT COUNT(*) FROM dwh.dwh_channels),
    (SELECT COUNT(*) FROM lnd.lnd_s1_channels) + (SELECT COUNT(*) FROM lnd.lnd_s2_channels)
UNION ALL
SELECT
    'dwh_products',
    (SELECT COUNT(*) FROM dwh.dwh_products),
    (SELECT COUNT(*) FROM lnd.lnd_s1_products) + (SELECT COUNT(DISTINCT product_id) FROM lnd.lnd_s2_client_sales)
UNION ALL
SELECT
    'dwh_locations',
    (SELECT COUNT(*) FROM dwh.dwh_locations),
    (SELECT COUNT(DISTINCT channellocation) FROM lnd.lnd_s1_channels) + (SELECT COUNT(*) FROM lnd.lnd_s2_locations)
UNION ALL
SELECT
    'dwh_sales',
    (SELECT COUNT(*) FROM dwh.dwh_sales),
    (SELECT COUNT(*) FROM lnd.lnd_s1_sales) + (SELECT COUNT(*) FROM lnd.lnd_s2_client_sales);



--C970: Exactly one current version per client in DWH_CLIENTS

SELECT client_src_id, COUNT(*) AS valid_count
FROM dwh.dwh_clients
WHERE is_valid = 'Y'
GROUP BY client_src_id
HAVING COUNT(*) <> 1
ORDER BY valid_count DESC;


--C1017 (Calculation Logic: TOTAL_COST result)

SELECT
    (SELECT SUM(total_cost) FROM dm.dm_main_dashboard) AS dm_total_cost_sum,
    (SELECT SUM(s.quantity * p.product_cost)
     FROM dwh.dwh_sales s
     JOIN dwh.dwh_products p ON s.product_id = p.product_id) AS dwh_calculated_sum;


SELECT
    (SELECT COUNT(*) FROM dm.dm_main_dashboard) AS dm_rows,
    (SELECT COUNT(*) FROM dwh.dwh_sales) AS dwh_sales_rows;

--C940: Phone number correctly combined from S2 into DWH_CLIENTS

SELECT
    s2.client_id AS src_client_id,
    s2.phone_code,
    s2.phone_number AS src_phone_number,
    dwh.phone_number AS dwh_phone_number,
    (s2.phone_code || s2.phone_number) AS expected_phone_number
FROM lnd.lnd_s2_clients s2
JOIN dwh.dwh_clients dwh ON dwh.client_src_id = s2.client_id
WHERE dwh.phone_number <> (s2.phone_code || s2.phone_number);

--C948 (Source COST converts correctly to DWH_PRODUCTS.PRODUCT_COST)

SELECT
    p.product_id,
    p.product_src_id,
    p.product_cost,
    pg_typeof(p.product_cost) AS actual_type
FROM dwh.dwh_products p
WHERE pg_typeof(p.product_cost)::text NOT LIKE '%numeric%';

-- S1-sourced products
SELECT trg.product_src_id, src.cost AS src_cost, trg.product_cost AS dwh_cost
FROM dwh.dwh_products trg
JOIN lnd.lnd_s1_products src ON src.product_id = trg.product_src_id
WHERE trg.product_cost <> CAST(src.cost AS NUMERIC(18,2));

-- S2-sourced products
SELECT trg.product_src_id, src.product_price AS src_price, trg.product_cost AS dwh_cost
FROM dwh.dwh_products trg
JOIN (SELECT DISTINCT product_id, product_price FROM lnd.lnd_s2_client_sales) src
    ON src.product_id = trg.product_src_id
WHERE trg.product_cost <> CAST(src.product_price AS NUMERIC(18,2));

--C995	Field-level data type correctness

SELECT table_name, column_name, data_type,
       character_maximum_length,
       numeric_precision,
       numeric_scale
FROM information_schema.columns
WHERE table_schema = 'dwh'
  AND table_name IN ('dwh_clients', 'dwh_products', 'dwh_channels', 'dwh_locations', 'dwh_sales')
ORDER BY table_name, ordinal_position;

SELECT table_name, column_name, data_type,
       character_maximum_length,
       numeric_precision,
       numeric_scale
FROM information_schema.columns
WHERE table_schema = 'dm'
  AND table_name = 'dm_main_dashboard'
ORDER BY table_name, ordinal_position;

--C1022: Orphan foreign keys are handled correctly

SELECT s.sale_id, s.client_id, s.product_id, s.channel_id
FROM dwh.dwh_sales s
LEFT JOIN dwh.dwh_clients c ON s.client_id = c.client_id
LEFT JOIN dwh.dwh_products p ON s.product_id = p.product_id
LEFT JOIN dwh.dwh_channels ch ON s.channel_id = ch.channel_id
WHERE c.client_id IS NULL
   OR p.product_id IS NULL
   OR ch.channel_id IS NULL;

SELECT DISTINCT dm.product_name
FROM dm.dm_main_dashboard dm
LEFT JOIN dwh.dwh_products p ON dm.product_name = p.product_name
WHERE p.product_name IS NULL;


SELECT DISTINCT dm.channel_name
FROM dm.dm_main_dashboard dm
LEFT JOIN dwh.dwh_channels c ON dm.channel_name = c.channel_name
WHERE c.channel_name IS NULL;

SELECT DISTINCT dm.location_name
FROM dm.dm_main_dashboard dm
LEFT JOIN dwh.dwh_locations l ON dm.location_name = l.location_name
WHERE l.location_name IS NULL;

--C1023	Null/Missing Mandatory Fields Validation

-- dwh_clients
SELECT client_id
FROM dwh.dwh_clients
WHERE client_id IS NULL OR first_name IS NULL OR last_name IS NULL;

-- dwh_products
SELECT product_id
FROM dwh.dwh_products
WHERE product_id IS NULL OR product_name IS NULL OR product_cost IS NULL;

-- dwh_sales
SELECT sale_id
FROM dwh.dwh_sales
WHERE sale_id IS NULL
   OR client_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR order_created IS NULL
   OR order_completed IS NULL;

-- C935	DWH tables has no duplicate values

-- dwh_clients (PK check — sanity only)
SELECT client_id, COUNT(*) AS duplicate_count
FROM dwh.dwh_clients
GROUP BY client_id
HAVING COUNT(*) > 1;

-- dwh_products (PK check — sanity only)
SELECT product_id, COUNT(*) AS duplicate_count
FROM dwh.dwh_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- dwh_sales — natural key duplicate check (the meaningful one)
SELECT client_id, channel_id, product_id, order_created, COUNT(*) AS duplicate_count
FROM dwh.dwh_sales
GROUP BY client_id, channel_id, product_id, order_created
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

--C936	The same records on both sources are not duplicated

SELECT client_src_id, COUNT(*) AS duplicate_count
FROM dwh.dwh_clients
GROUP BY client_src_id
HAVING COUNT(*) > 1;

SELECT channel_src_id, COUNT(*) AS duplicate_count
FROM dwh.dwh_channels
GROUP BY channel_src_id
HAVING COUNT(*) > 1;

SELECT product_src_id, COUNT(*) AS duplicate_count
FROM dwh.dwh_products
GROUP BY product_src_id
HAVING COUNT(*) > 1;

--C938	Aggregations are consistent across layers - covered in C1017

--C1005	VALID_FROM/VALID_TO placeholder values are consistent
SELECT client_src_id, valid_from, valid_to, is_valid
FROM dwh.dwh_clients c
WHERE c.client_id IN (
    SELECT client_id FROM dwh.dwh_clients WHERE client_src_id IN (SELECT client_id FROM lnd.lnd_s1_clients)
)
AND (valid_from <> '2000-01-01' OR valid_to <> '2100-01-01');

SELECT COUNT(*) AS total_s1_clients,
       COUNT(*) FILTER (WHERE valid_to = '2000-01-01') AS wrong_valid_to,
       COUNT(*) FILTER (WHERE valid_to = '2100-01-01') AS correct_valid_to
FROM dwh.dwh_clients
WHERE client_src_id IN (SELECT client_id FROM lnd.lnd_s1_clients);

SELECT client_src_id, valid_from, valid_to, is_valid
FROM dwh.dwh_clients
WHERE client_src_id IN (SELECT client_id FROM lnd.lnd_s2_clients)
  AND ((valid_to > '2021-01-20' AND is_valid <> 'Y')
    OR (valid_to <= '2021-01-20' AND is_valid <> 'N'));

--C1004	Full SCD2 history is retrievable and consistent

-- Overlap check
SELECT a.client_src_id, a.client_id AS id_1, b.client_id AS id_2,
       a.valid_from AS from_1, a.valid_to AS to_1,
       b.valid_from AS from_2, b.valid_to AS to_2
FROM dwh.dwh_clients a
JOIN dwh.dwh_clients b ON a.client_src_id = b.client_src_id AND a.client_id <> b.client_id
WHERE a.valid_from < COALESCE(b.valid_to, '9999-12-31')
  AND b.valid_from < COALESCE(a.valid_to, '9999-12-31');

-- Sequencing check
SELECT client_src_id, client_id, valid_from, valid_to
FROM dwh.dwh_clients
WHERE valid_from >= valid_to;


--C1008	Boundary values are handled correctly

SELECT sale_id, quantity FROM dwh.dwh_sales WHERE quantity <= 0;
SELECT product_id, product_cost FROM dwh.dwh_products WHERE product_cost < 0;
