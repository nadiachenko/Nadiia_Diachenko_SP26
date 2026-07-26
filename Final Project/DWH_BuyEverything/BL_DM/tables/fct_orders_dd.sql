CREATE TABLE bl_dm.fct_orders_dd (
    order_surr_id             BIGINT NOT NULL,
    event_dt                  DATE   NOT NULL,
    product_surr_id           BIGINT NOT NULL,
    customer_surr_id          BIGINT NOT NULL,
    sales_rep_surr_id         BIGINT NOT NULL,
    city_surr_id              BIGINT NOT NULL,
    subchannel_surr_id        BIGINT NOT NULL,
    order_status              VARCHAR NOT NULL,
    returned                  VARCHAR NOT NULL,
    payment_method            VARCHAR NOT NULL,
    fct_unit_price            NUMERIC(10,2) NOT NULL,
    fct_quantity              BIGINT NOT NULL,
    fct_discount_percent      BIGINT NOT NULL,
    fct_discount_amount       NUMERIC(10,2) NOT NULL,
    fct_shipping_cost         NUMERIC(10,2) NOT NULL,
    fct_tax_amount            NUMERIC(10,2) NOT NULL,
    fct_order_amount          NUMERIC(10,2) NOT NULL,
    fct_cost_amount           NUMERIC(10,2) NOT NULL,
    fct_profit_margin_percent NUMERIC(10,2) NOT NULL,
    fct_profit_amount         NUMERIC(10,2) NOT NULL,
    fct_net_amount            NUMERIC(10,2) NOT NULL,
    transaction_id            VARCHAR NOT NULL,
    source_system             VARCHAR NOT NULL,
    source_entity             VARCHAR NOT NULL,
    order_src_id              VARCHAR NOT NULL,
    insert_dt                 DATE NOT NULL,
    update_dt                 DATE NOT NULL,
    CONSTRAINT pk_fct_orders_dd PRIMARY KEY (order_src_id, source_system, event_dt)
) PARTITION BY RANGE (event_dt);

CREATE TABLE IF NOT EXISTS bl_dm.fct_orders_dd_default PARTITION OF bl_dm.fct_orders_dd DEFAULT;

ALTER TABLE bl_dm.fct_orders_dd
    ADD CONSTRAINT fk_fct_orders_dd_dates FOREIGN KEY (event_dt) REFERENCES bl_dm.dim_dates (date_key);


