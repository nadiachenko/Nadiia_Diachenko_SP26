CREATE OR REPLACE FUNCTION bl_cl.get_load_summary()
RETURNS TABLE (
    log_id         BIGINT,
    log_dt         TIMESTAMP,
    procedure_name VARCHAR,
    log_status     VARCHAR,
    rows_affected  INT,
    log_message    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.log_dt, l.procedure_name, l.log_status, l.rows_affected, l.log_message
    FROM bl_cl.mta_load_logs l
    ORDER BY l.log_id DESC;
END;
$$;
