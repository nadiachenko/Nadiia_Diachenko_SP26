CREATE OR REPLACE PROCEDURE bl_cl.run_all_tests()
LANGUAGE plpgsql
AS $$
DECLARE
    rec              RECORD;
    v_actual         BIGINT;
    v_status         VARCHAR;
    v_pass           INT := 0;
    v_fail           INT := 0;
    v_summary_status VARCHAR;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.mta_test_cases WHERE is_active ORDER BY test_id LOOP
        BEGIN
            EXECUTE rec.test_sql INTO v_actual;
            IF rec.test_type = 'ASSERT_ZERO' THEN
                IF v_actual = 0 THEN 
                    v_status := 'PASS'; 
                    v_pass   := v_pass + 1;
                ELSE                 
                    v_status := 'FAIL'; 
                    v_fail   := v_fail + 1;
                END IF;
            ELSE
                v_status := 'INFO';
            END IF;

            INSERT INTO bl_cl.mta_test_results (test_id, test_name, test_group, actual_value, status, message)
            VALUES (rec.test_id, rec.test_name, rec.test_group, v_actual, v_status,
                    rec.test_type || ' -> ' || v_actual);

        EXCEPTION WHEN OTHERS THEN
            v_fail := v_fail + 1;
            -- Capture both SQLSTATE and SQLERRM for individual failing test queries
            INSERT INTO bl_cl.mta_test_results (test_id, test_name, test_group, actual_value, status, message)
            VALUES (rec.test_id, rec.test_name, rec.test_group, NULL, 'ERROR', 
                    '[' || SQLSTATE || '] ' || SQLERRM);
        END;
    END LOOP;

    -- Flag overall run status: ERROR if any test cases failed or threw runtime exceptions
    IF v_fail > 0 THEN
        v_summary_status := 'ERROR';
    ELSE
        v_summary_status := 'SUCCESS';
    END IF;

    -- Log test execution summary to mta_load_logs
    CALL bl_cl.p_log('run_all_tests', v_summary_status, v_pass + v_fail,
                     'Passed: ' || v_pass || ', Failed: ' || v_fail);

EXCEPTION WHEN OTHERS THEN
    -- Top-level error logging with 5 parameters and explicit re-raise
    CALL bl_cl.p_log('run_all_tests', 'ERROR', NULL, SQLERRM, SQLSTATE);
    RAISE;
END;
$$;