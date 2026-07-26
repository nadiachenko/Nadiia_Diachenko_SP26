CREATE SEQUENCE IF NOT EXISTS bl_dm.seq_dim_employees_surr_id START WITH 1;

CREATE TABLE IF NOT EXISTS bl_dm.dim_employees (
    sales_rep_surr_id BIGINT NOT NULL,
    sales_rep_first_name VARCHAR NOT NULL,
    sales_rep_last_name VARCHAR NOT NULL,
    sales_rep_email VARCHAR NOT NULL,
    source_system VARCHAR NOT NULL,
    source_entity VARCHAR NOT NULL,
    sales_rep_src_id VARCHAR NOT NULL,
    insert_dt DATE NOT NULL,
    update_dt DATE NOT NULL,
    CONSTRAINT pk_dim_employees PRIMARY KEY (sales_rep_surr_id)
);

-- default (-1) row
INSERT INTO bl_dm.dim_employees (
    sales_rep_surr_id, sales_rep_src_id, sales_rep_first_name, sales_rep_last_name, 
    sales_rep_email, source_system, source_entity, insert_dt, update_dt
)
SELECT -1, 'n. a.', 'n. a.', 'n. a.', 'n. a.', 'MANUAL', 'MANUAL', '1900-01-01'::DATE, '1900-01-01'::DATE
WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_employees WHERE sales_rep_surr_id = -1);
