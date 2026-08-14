CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_customers_surr_id START WITH 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_customers_scd (
    customer_surr_id BIGINT NOT NULL,
    customer_first_name VARCHAR NOT NULL,
    customer_last_name VARCHAR NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_age VARCHAR NOT NULL,
    customer_gender VARCHAR NOT NULL,
    customer_segment VARCHAR NOT NULL,
    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    is_active VARCHAR(1) NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    customer_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_customers_scd PRIMARY KEY (customer_surr_id)
);

-- default (-1) row
INSERT INTO bl_dm.dim_customers_scd (
    customer_surr_id, customer_src_id, customer_first_name, customer_last_name, 
    customer_email, customer_age, customer_gender, customer_segment, 
    start_dt, end_dt, is_active, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 
       '1900-01-01'::DATE, '9999-12-31'::DATE, 'Y', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_customers_scd WHERE customer_surr_id = -1);
