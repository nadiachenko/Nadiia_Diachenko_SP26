CREATE OR REPLACE PROCEDURE bl_cl.p_log(
    p_procedure_name VARCHAR,
    p_log_status     VARCHAR,
    p_rows_affected  INT,
    p_log_message    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bl_cl.mta_load_logs (procedure_name, log_status, rows_affected, log_message)
    VALUES (p_procedure_name, p_log_status, p_rows_affected, p_log_message);
END;
$$;
