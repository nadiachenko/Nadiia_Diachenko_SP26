-- junk dimension
CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_order_details_surr_id START WITH 1;

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

-- default (-1) row
INSERT INTO bl_dm.dim_orders_details (
    order_surr_id, order_status, returned, payment_method, 
    source_system, source_entity, order_src_id, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_orders_details WHERE order_surr_id = -1);
