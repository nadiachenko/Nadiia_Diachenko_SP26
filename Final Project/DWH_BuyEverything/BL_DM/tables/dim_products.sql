CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_products_surr_id START WITH 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_products (
    product_surr_id BIGINT NOT NULL,   
    product_subcategory_id BIGINT NOT NULL,
    product_subcategory_name VARCHAR NOT NULL,
    product_category_id BIGINT NOT NULL,
    product_category_name VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    product_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_products PRIMARY KEY (product_surr_id)
);

-- default (-1) row
INSERT INTO bl_dm.dim_products (
    product_surr_id, product_src_id, product_subcategory_id, product_subcategory_name,
    product_category_id, product_category_name, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', -1, 'n. a.', -1, 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_products WHERE product_surr_id = -1);
