CREATE OR REPLACE PROCEDURE bl_cl.load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_ins INT = 0;
    v_rows_upd INT = 0;
    v_tmp      INT = 0;
    v_cur      refcursor;   
    v_src_id   VARCHAR;
    v_fname    VARCHAR;
    v_lname    VARCHAR;
    v_email    VARCHAR;
BEGIN
    OPEN v_cur FOR
        SELECT sales_rep_id::VARCHAR AS sales_rep_src_id,
               sales_rep_first_name, sales_rep_last_name, sales_rep_email
        FROM bl_3nf.ce_employees
        WHERE sales_rep_id <> -1;

    LOOP
        FETCH v_cur INTO v_src_id, v_fname, v_lname, v_email;
        EXIT WHEN NOT FOUND;

        UPDATE bl_dm.dim_employees tgt
        SET sales_rep_first_name = v_fname,
            sales_rep_last_name  = v_lname,
            sales_rep_email      = v_email,
            update_dt = CURRENT_DATE
        WHERE tgt.sales_rep_src_id = v_src_id
          AND tgt.source_system    = 'BL_3NF'
          AND (tgt.sales_rep_first_name IS DISTINCT FROM v_fname
            OR tgt.sales_rep_last_name  IS DISTINCT FROM v_lname
            OR tgt.sales_rep_email      IS DISTINCT FROM v_email);
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_upd = v_rows_upd + v_tmp;

        INSERT INTO bl_dm.dim_employees (
            sales_rep_surr_id, sales_rep_first_name, sales_rep_last_name,
            sales_rep_email, source_system, source_entity, sales_rep_src_id,
            insert_dt, update_dt)
        SELECT nextval('bl_dm.seq_dim_employees_surr_id'),
               v_fname, v_lname, v_email, 'BL_3NF', 'CE_EMPLOYEES', v_src_id,
               CURRENT_DATE, CURRENT_DATE
        WHERE NOT EXISTS (SELECT 1 FROM bl_dm.dim_employees tgt
            WHERE tgt.sales_rep_src_id = v_src_id AND tgt.source_system = 'BL_3NF');
        GET DIAGNOSTICS v_tmp = ROW_COUNT; v_rows_ins = v_rows_ins + v_tmp;
    END LOOP;
    CLOSE v_cur;   -- release the cursor
    CALL bl_cl.p_log('load_dim_employees', 'SUCCESS', v_rows_ins + v_rows_upd,
                     'Inserted: ' || v_rows_ins || ', Updated: ' || v_rows_upd || ' (cursor variable)');
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('load_dim_employees', 'ERROR', NULL, SQLERRM);
END;
$$;
