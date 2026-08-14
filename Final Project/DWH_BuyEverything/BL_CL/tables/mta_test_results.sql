CREATE SEQUENCE IF NOT EXISTS bl_cl.seq_mta_test_results_id START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS bl_cl.mta_test_results (
    result_id    BIGINT DEFAULT nextval('bl_cl.seq_mta_test_results_id') NOT NULL,
    run_dt       TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    test_id      BIGINT NOT NULL,
    test_name    VARCHAR NOT NULL,
    test_group   VARCHAR NOT NULL,
    actual_value BIGINT,
    status       VARCHAR NOT NULL,
    message      TEXT,
    CONSTRAINT pk_mta_test_results PRIMARY KEY (result_id)
);
