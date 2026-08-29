CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_customers_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_customers_scd (
    customer_id BIGINT NOT NULL,
    customer_first_name VARCHAR NOT NULL,
    customer_last_name VARCHAR NOT NULL,
    customer_email VARCHAR NOT NULL,
    customer_age VARCHAR NOT NULL,
    customer_gender VARCHAR NOT NULL,
    customer_segment VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    customer_src_id VARCHAR NOT NULL,
    is_active VARCHAR(1) NOT NULL,
    start_dt DATE NOT NULL,
    end_dt DATE NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_customers_scd PRIMARY KEY (customer_id, start_dt)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_customers_scd (customer_id, customer_first_name, customer_last_name, customer_email, customer_age, customer_gender, customer_segment, source_system, source_entity, customer_src_id, is_active, start_dt, end_dt, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', 'Y', '1900-01-01', '9999-12-31', '1900-01-01', '1900-01-01') 
ON CONFLICT (customer_id, start_dt) DO NOTHING;
