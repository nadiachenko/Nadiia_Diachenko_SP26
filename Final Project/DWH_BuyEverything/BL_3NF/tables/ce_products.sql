CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_products_id START WITH 100 INCREMENT BY 1;

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

-- default (-1) row
INSERT INTO bl_3nf.ce_products (product_id, product_subcategory_id, source_system, source_entity, product_src_id, insert_dt, update_dt) 
VALUES (-1, -1, 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (product_id) DO NOTHING;
