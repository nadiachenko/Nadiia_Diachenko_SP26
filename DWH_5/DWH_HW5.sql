
CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS file_server FOREIGN DATA WRAPPER file_fdw;


-- 1. DATASET 1: INTERNATIONAL SALES 

CREATE SCHEMA IF NOT EXISTS sa_int_sales;

-- External Virtual Table 
CREATE FOREIGN TABLE IF NOT EXISTS sa_int_sales.ext_int_sales (
    ORDER_ID_INT                 VARCHAR,
    CUSTOMER_ID_INT              VARCHAR,
    CUSTOMER_FIRST_NAME_INT      VARCHAR,
    CUSTOMER_LAST_NAME_INT       VARCHAR,
    CUSTOMER_EMAIL_INT           VARCHAR,
    ORDER_DT_INT                 VARCHAR,
    COUNTRY                      VARCHAR,
    CITY_INT                     VARCHAR,
    CUSTOMER_STATUS              VARCHAR,
    PRODUCT_ID_INT               VARCHAR,
    CATEGORY                     VARCHAR,
    SUBCATEGORY                  VARCHAR,
    PRICE                        VARCHAR,
    QUANTITY_INT                 VARCHAR,
    DISCOUNT_PERCENT_INT         VARCHAR,
    DISCOUNT_AMOUNT_INT          VARCHAR,
    SHIPPING_COST_INT            VARCHAR,
    TAX                          VARCHAR,
    ORDER_AMOUNT_INT             VARCHAR,
    PAYMENT                      VARCHAR,
    ORDER_STATUS_INT             VARCHAR,
    RETURNED                     VARCHAR,
    PPROFIT_MARGIN_PERCENT_INT   VARCHAR,
    PROFIT_AMOUNT_INT            VARCHAR,
    SALES_REP_ID_INT             VARCHAR,
    SALES_REP_FIRST_NAME_INT     VARCHAR,
    SALES_REP_LAST_NAME_INT      VARCHAR,
    SALES_REP_EMAIL_INT          VARCHAR,
    COST_AMOUNT_INT              VARCHAR,
    CHANNEL                      VARCHAR,
    SUBCHANNEL                   VARCHAR
) 
SERVER file_server
OPTIONS ( 
    filename 'C:/datasets/SRC_INTERNATIONAL_SALES.csv',
    format 'csv', 
    header 'true',
    delimiter ','
);

-- Physical Table 
CREATE TABLE IF NOT EXISTS sa_int_sales.src_int_sales (
    ORDER_ID_INT                 VARCHAR,
    CUSTOMER_ID_INT              VARCHAR,
    CUSTOMER_FIRST_NAME_INT      VARCHAR,
    CUSTOMER_LAST_NAME_INT       VARCHAR,
    CUSTOMER_EMAIL_INT           VARCHAR,
    ORDER_DT_INT                 VARCHAR,
    COUNTRY                      VARCHAR,
    CITY_INT                     VARCHAR,
    CUSTOMER_STATUS              VARCHAR,
    PRODUCT_ID_INT               VARCHAR,
    CATEGORY                     VARCHAR,
    SUBCATEGORY                  VARCHAR,
    PRICE                        VARCHAR,
    QUANTITY_INT                 VARCHAR,
    DISCOUNT_PERCENT_INT         VARCHAR,
    DISCOUNT_AMOUNT_INT          VARCHAR,
    SHIPPING_COST_INT            VARCHAR,
    TAX                          VARCHAR,
    ORDER_AMOUNT_INT             VARCHAR,
    PAYMENT                      VARCHAR,
    ORDER_STATUS_INT             VARCHAR,
    RETURNED                     VARCHAR,
    PPROFIT_MARGIN_PERCENT_INT   VARCHAR,
    PROFIT_AMOUNT_INT            VARCHAR,
    SALES_REP_ID_INT             VARCHAR,
    SALES_REP_FIRST_NAME_INT     VARCHAR,
    SALES_REP_LAST_NAME_INT      VARCHAR,
    SALES_REP_EMAIL_INT          VARCHAR,
    COST_AMOUNT_INT              VARCHAR,
    CHANNEL                      VARCHAR,
    SUBCHANNEL                   VARCHAR,
    insert_date                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



INSERT INTO sa_int_sales.src_int_sales (
    ORDER_ID_INT, CUSTOMER_ID_INT, CUSTOMER_FIRST_NAME_INT, CUSTOMER_LAST_NAME_INT,
    CUSTOMER_EMAIL_INT, ORDER_DT_INT, COUNTRY, CITY_INT, CUSTOMER_STATUS,
    PRODUCT_ID_INT, CATEGORY, SUBCATEGORY, PRICE, QUANTITY_INT, DISCOUNT_PERCENT_INT,
    DISCOUNT_AMOUNT_INT, SHIPPING_COST_INT, TAX, ORDER_AMOUNT_INT, PAYMENT,
    ORDER_STATUS_INT, RETURNED, PPROFIT_MARGIN_PERCENT_INT, PROFIT_AMOUNT_INT,
    SALES_REP_ID_INT, SALES_REP_FIRST_NAME_INT, SALES_REP_LAST_NAME_INT,
    SALES_REP_EMAIL_INT, COST_AMOUNT_INT, CHANNEL, SUBCHANNEL
)
SELECT 
    source.ORDER_ID_INT, source.CUSTOMER_ID_INT, source.CUSTOMER_FIRST_NAME_INT, source.CUSTOMER_LAST_NAME_INT,
    source.CUSTOMER_EMAIL_INT, source.ORDER_DT_INT, source.COUNTRY, source.CITY_INT, source.CUSTOMER_STATUS,
    source.PRODUCT_ID_INT, source.CATEGORY, source.SUBCATEGORY, source.PRICE, source.QUANTITY_INT, source.DISCOUNT_PERCENT_INT,
    source.DISCOUNT_AMOUNT_INT, source.SHIPPING_COST_INT, source.TAX, source.ORDER_AMOUNT_INT, source.PAYMENT,
    source.ORDER_STATUS_INT, source.RETURNED, source.PPROFIT_MARGIN_PERCENT_INT, source.PROFIT_AMOUNT_INT,
    source.SALES_REP_ID_INT, source.SALES_REP_FIRST_NAME_INT, source.SALES_REP_LAST_NAME_INT,
    source.SALES_REP_EMAIL_INT, source.COST_AMOUNT_INT, source.CHANNEL, source.SUBCHANNEL
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID_INT 
            ORDER BY ORDER_DT_INT DESC
        ) as rn
    FROM sa_int_sales.ext_int_sales
) source
WHERE source.rn = 1
  AND NOT EXISTS (
      SELECT 1 
      FROM sa_int_sales.src_int_sales target
      WHERE target.ORDER_ID_INT = source.ORDER_ID_INT
  );



-- 2. DATASET 2: US SALES (sa_us_sales)


CREATE SCHEMA IF NOT EXISTS sa_us_sales;

-- External Virtual Table 
CREATE FOREIGN TABLE IF NOT EXISTS sa_us_sales.ext_us_sales (
    ORDER_ID                 VARCHAR,
    CUSTOMER_ID              VARCHAR,
    CUSTOMER_FIRST_NAME      VARCHAR,
    CUSTOMER_LAST_NAME       VARCHAR,
    CUSTOMER_EMAIL           VARCHAR,
    ORDER_DT                 VARCHAR,
    CUSTOMER_AGE             VARCHAR,
    CUSTOMER_GENDER          VARCHAR,
    STATE                    VARCHAR,
    CITY                     VARCHAR,
    CUSTOMER_SEGMENT         VARCHAR,
    PRODUCT_ID               VARCHAR,
    PRODUCT_CATEGORY         VARCHAR,
    PRODUCT_SUBCATEGORY      VARCHAR,
    UNIT_PRICE               VARCHAR,
    QUANTITY                 VARCHAR,
    DISCOUNT_PERCENT         VARCHAR,
    DISCOUNT_AMOUNT          VARCHAR,
    SHIPPING_COST            VARCHAR,
    TAX_AMOUNT               VARCHAR,
    ORDER_AMOUNT             VARCHAR,
    PAYMENT_METHOD           VARCHAR,
    ORDER_STATUS             VARCHAR,
    RETURNED                 VARCHAR,
    PROFIT_MARGIN_PERCENT    VARCHAR,
    PROFIT_MARGIN_AMOUNT     VARCHAR,
    SALES_REP_ID             VARCHAR,
    SALES_REP_FIRST_NAME     VARCHAR,
    SALES_REP_LAST_NAME      VARCHAR,
    SALES_REP_EMAIL          VARCHAR,
    COST_AMOUNT              VARCHAR,
    CHANNEL                  VARCHAR,
    SUBCHANNEL               VARCHAR
) 
SERVER file_server
OPTIONS ( 
    filename 'C:/datasets/SRC_US_SALES.csv',
    format 'csv', 
    header 'true',
    delimiter ','
);

-- Physical Staging Table 
CREATE TABLE IF NOT EXISTS sa_us_sales.src_us_sales (
    ORDER_ID                 VARCHAR,
    CUSTOMER_ID              VARCHAR,
    CUSTOMER_FIRST_NAME      VARCHAR,
    CUSTOMER_LAST_NAME       VARCHAR,
    CUSTOMER_EMAIL           VARCHAR,
    ORDER_DT                 VARCHAR,
    CUSTOMER_AGE             VARCHAR,
    CUSTOMER_GENDER          VARCHAR,
    STATE                    VARCHAR,
    CITY                     VARCHAR,
    CUSTOMER_SEGMENT         VARCHAR,
    PRODUCT_ID               VARCHAR,
    PRODUCT_CATEGORY         VARCHAR,
    PRODUCT_SUBCATEGORY      VARCHAR,
    UNIT_PRICE               VARCHAR,
    QUANTITY                 VARCHAR,
    DISCOUNT_PERCENT         VARCHAR,
    DISCOUNT_AMOUNT          VARCHAR,
    SHIPPING_COST            VARCHAR,
    TAX_AMOUNT               VARCHAR,
    ORDER_AMOUNT             VARCHAR,
    PAYMENT_METHOD           VARCHAR,
    ORDER_STATUS             VARCHAR,
    RETURNED                 VARCHAR,
    PROFIT_MARGIN_PERCENT    VARCHAR,
    PROFIT_MARGIN_AMOUNT     VARCHAR,
    SALES_REP_ID             VARCHAR,
    SALES_REP_FIRST_NAME     VARCHAR,
    SALES_REP_LAST_NAME      VARCHAR,
    SALES_REP_EMAIL          VARCHAR,
    COST_AMOUNT              VARCHAR,
    CHANNEL                  VARCHAR,
    SUBCHANNEL               VARCHAR,
    insert_date              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO sa_us_sales.src_us_sales (
    ORDER_ID, CUSTOMER_ID, CUSTOMER_FIRST_NAME, CUSTOMER_LAST_NAME, CUSTOMER_EMAIL,
    ORDER_DT, CUSTOMER_AGE, CUSTOMER_GENDER, STATE, CITY, CUSTOMER_SEGMENT,
    PRODUCT_ID, PRODUCT_CATEGORY, PRODUCT_SUBCATEGORY, UNIT_PRICE, QUANTITY,
    DISCOUNT_PERCENT, DISCOUNT_AMOUNT, SHIPPING_COST, TAX_AMOUNT, ORDER_AMOUNT,
    PAYMENT_METHOD, ORDER_STATUS, RETURNED, PROFIT_MARGIN_PERCENT, PROFIT_MARGIN_AMOUNT,
    SALES_REP_ID, SALES_REP_FIRST_NAME, SALES_REP_LAST_NAME, SALES_REP_EMAIL,
    COST_AMOUNT, CHANNEL, SUBCHANNEL
)
SELECT 
    source.ORDER_ID, source.CUSTOMER_ID, source.CUSTOMER_FIRST_NAME, source.CUSTOMER_LAST_NAME, source.CUSTOMER_EMAIL,
    source.ORDER_DT, source.CUSTOMER_AGE, source.CUSTOMER_GENDER, source.STATE, source.CITY, source.CUSTOMER_SEGMENT,
    source.PRODUCT_ID, source.PRODUCT_CATEGORY, source.PRODUCT_SUBCATEGORY, source.UNIT_PRICE, source.QUANTITY,
    source.DISCOUNT_PERCENT, source.DISCOUNT_AMOUNT, source.SHIPPING_COST, source.TAX_AMOUNT, source.ORDER_AMOUNT,
    source.PAYMENT_METHOD, source.ORDER_STATUS, source.RETURNED, source.PROFIT_MARGIN_PERCENT, source.PROFIT_MARGIN_AMOUNT,
    source.SALES_REP_ID, source.SALES_REP_FIRST_NAME, source.SALES_REP_LAST_NAME, source.SALES_REP_EMAIL,
    source.COST_AMOUNT, source.CHANNEL, source.SUBCHANNEL
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID 
            ORDER BY ORDER_DT DESC
        ) as rn
    FROM sa_us_sales.ext_us_sales
) source
WHERE source.rn = 1
  AND NOT EXISTS (
      SELECT 1 
      FROM sa_us_sales.src_us_sales target
      WHERE target.ORDER_ID = source.ORDER_ID
  );


-- 3. TESTING

SELECT * FROM sa_int_sales.ext_int_sales LIMIT 15;
SELECT * FROM sa_int_sales.src_int_sales LIMIT 15;

SELECT * FROM sa_us_sales.ext_us_sales LIMIT 15;
SELECT * FROM sa_us_sales.src_us_sales LIMIT 15;