CREATE SEQUENCE IF NOT EXISTS bl_cl.seq_mta_load_logs_id START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_cl.mta_load_logs (
    log_id         BIGINT DEFAULT nextval('bl_cl.seq_mta_load_logs_id') NOT NULL,
    log_dt         TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    procedure_name VARCHAR NOT NULL,
    log_status     VARCHAR NOT NULL,
    rows_affected  INT,
    log_message    TEXT,
    CONSTRAINT pk_mta_load_logs PRIMARY KEY (log_id),
    CONSTRAINT chk_mta_load_logs_status CHECK (log_status IN ('SUCCESS','ERROR'))
);
