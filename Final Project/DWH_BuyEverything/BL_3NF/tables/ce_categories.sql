CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_categories_id START WITH 100 INCREMENT BY 1;

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

-- default (-1) row
INSERT INTO bl_3nf.ce_categories (product_category_id, product_category_name, source_system, source_entity, product_category_name_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (product_category_id) DO NOTHING;
