--current partitions
SELECT tableoid::regclass AS partition, COUNT(*)
FROM bl_dm.fct_orders_dd
GROUP BY tableoid
ORDER BY 1;

CALL bl_cl.load_fct_auto(3)

SELECT count(*) AS ce_orders_before FROM bl_3nf.ce_orders;
SELECT count(*) AS fct_rows_before  FROM bl_dm.fct_orders_dd;

--INSERT of increment
INSERT INTO sa_us_sales.src_us_sales (
    ORDER_ID,
    CUSTOMER_ID,
    CUSTOMER_FIRST_NAME,
    CUSTOMER_LAST_NAME,
    CUSTOMER_EMAIL,
    ORDER_DT,
    CUSTOMER_AGE,
    CUSTOMER_GENDER,
    STATE,
    CITY,
    CUSTOMER_SEGMENT,
    PRODUCT_ID,
    PRODUCT_CATEGORY,
    PRODUCT_SUBCATEGORY,
    UNIT_PRICE,
    QUANTITY,
    DISCOUNT_PERCENT,
    DISCOUNT_AMOUNT,
    SHIPPING_COST,
    TAX_AMOUNT,
    ORDER_AMOUNT,
    PAYMENT_METHOD,
    ORDER_STATUS,
    RETURNED,
    PROFIT_MARGIN_PERCENT,
    PROFIT_MARGIN_AMOUNT,
    SALES_REP_ID,
    SALES_REP_FIRST_NAME,
    SALES_REP_LAST_NAME,
    SALES_REP_EMAIL,
    COST_AMOUNT,
    CHANNEL,
    SUBCHANNEL
)
SELECT
    source.ORDER_ID,
    source.CUSTOMER_ID,
    source.CUSTOMER_FIRST_NAME,
    source.CUSTOMER_LAST_NAME,
    source.CUSTOMER_EMAIL,
    source.ORDER_DT,
    source.CUSTOMER_AGE,
    source.CUSTOMER_GENDER,
    source.STATE,
    source.CITY,
    source.CUSTOMER_SEGMENT,
    source.PRODUCT_ID,
    source.PRODUCT_CATEGORY,
    source.PRODUCT_SUBCATEGORY,
    source.UNIT_PRICE,
    source.QUANTITY,
    source.DISCOUNT_PERCENT,
    source.DISCOUNT_AMOUNT,
    source.SHIPPING_COST,
    source.TAX_AMOUNT,
    source.ORDER_AMOUNT,
    source.PAYMENT_METHOD,
    source.ORDER_STATUS,
    source.RETURNED,
    source.PROFIT_MARGIN_PERCENT,
    source.PROFIT_MARGIN_AMOUNT,
    source.SALES_REP_ID,
    source.SALES_REP_FIRST_NAME,
    source.SALES_REP_LAST_NAME,
    source.SALES_REP_EMAIL,
    source.COST_AMOUNT,
    source.CHANNEL,
    source.SUBCHANNEL
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID ORDER BY ORDER_DT DESC) AS rn
    FROM sa_us_sales.ext_us_sales_new
) source
WHERE source.rn = 1
  AND NOT EXISTS (
      SELECT 1 FROM sa_us_sales.src_us_sales target
      WHERE target.ORDER_ID = source.ORDER_ID
  );

--load data
CALL bl_cl.load_all(3); 

-- 3NF and fact grew
SELECT count(*) AS ce_orders_after FROM bl_3nf.ce_orders;
SELECT count(*) AS fct_rows_after  FROM bl_dm.fct_orders_dd;

--check partitions
SELECT tableoid::regclass AS partition, COUNT(*)
FROM bl_dm.fct_orders_dd
GROUP BY tableoid
ORDER BY 1;

-- no duplicates (the key test)
SELECT order_src_id, source_system, count(*)
FROM bl_dm.fct_orders_dd
GROUP BY order_src_id, source_system HAVING count(*) > 1; 

--check log
SELECT procedure_name, log_status, rows_affected, log_message
FROM bl_cl.mta_load_logs ORDER BY log_id DESC LIMIT 15;