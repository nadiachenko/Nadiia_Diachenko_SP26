CREATE SEQUENCE IF NOT EXISTS bl_3nf.seq_employees_id START WITH 100 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_employees (
    sales_rep_id BIGINT NOT NULL,
    sales_rep_first_name VARCHAR NOT NULL,
    sales_rep_last_name VARCHAR NOT NULL,
    sales_rep_email VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    sales_rep_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_ce_employees PRIMARY KEY (sales_rep_id)
);

-- default (-1) row
INSERT INTO bl_3nf.ce_employees (sales_rep_id, sales_rep_first_name, sales_rep_last_name, sales_rep_email, source_system, source_entity, sales_rep_src_id, insert_dt, update_dt) 
VALUES (-1, 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', 'n. a.', '1900-01-01', '1900-01-01') 
ON CONFLICT (sales_rep_id) DO NOTHING;
