CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_orders_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_orders (
    order_id              BIGINT NOT NULL,
    order_dt              DATE NOT NULL,
    order_status          VARCHAR NOT NULL,
    returned              VARCHAR NOT NULL,
    customer_id           BIGINT NOT NULL,
    sales_rep_id          BIGINT NOT NULL,
    product_id            BIGINT NOT NULL,
    subchannel_id         BIGINT NOT NULL,
    city_id               BIGINT NOT NULL,
    payment_method        VARCHAR NOT NULL,
    unit_price            NUMERIC(10,2) NOT NULL,
    quantity              BIGINT NOT NULL,
    discount_percent      BIGINT NOT NULL,
    discount_amount       NUMERIC(10,2) NOT NULL,
    shipping_cost         NUMERIC(10,2) NOT NULL,
    tax_amount            NUMERIC(10,2) NOT NULL,
    order_amount          NUMERIC(10,2) NOT NULL,
    cost_amount           NUMERIC(10,2) NOT NULL,
    profit_margin_percent NUMERIC(10,2) NOT NULL,
    profit_amount         NUMERIC(10,2) NOT NULL,
    transaction_id        VARCHAR NOT NULL,
    source_system         VARCHAR NOT NULL,
    source_entity         VARCHAR NOT NULL,
    order_src_id          VARCHAR NOT NULL,
    insert_dt             DATE NOT NULL,
    update_dt             DATE NOT NULL,
    CONSTRAINT pk_ce_orders PRIMARY KEY (order_id),
    CONSTRAINT uq_ce_orders_bk UNIQUE (order_src_id, source_system),
    CONSTRAINT fk_ce_orders_employee   FOREIGN KEY (sales_rep_id)  REFERENCES bl_3nf.ce_employees(sales_rep_id),
    CONSTRAINT fk_ce_orders_product    FOREIGN KEY (product_id)    REFERENCES bl_3nf.ce_products(product_id),
    CONSTRAINT fk_ce_orders_subchannel FOREIGN KEY (subchannel_id) REFERENCES bl_3nf.ce_subchannels(subchannel_id),
    CONSTRAINT fk_ce_orders_city       FOREIGN KEY (city_id)       REFERENCES bl_3nf.ce_cities(city_id)
);

CREATE INDEX IF NOT EXISTS idx_ce_orders_update_dt ON bl_3nf.ce_orders (update_dt);
CREATE INDEX IF NOT EXISTS idx_ce_orders_order_dt  ON bl_3nf.ce_orders (order_dt);


