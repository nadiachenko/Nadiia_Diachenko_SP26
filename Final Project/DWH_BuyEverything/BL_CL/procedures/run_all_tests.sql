CREATE OR REPLACE PROCEDURE bl_cl.run_all_tests()
LANGUAGE plpgsql
AS $$
DECLARE
    rec      RECORD;
    v_actual BIGINT;
    v_status VARCHAR;
    v_pass   INT := 0;
    v_fail   INT := 0;
BEGIN
    FOR rec IN SELECT * FROM bl_cl.mta_test_cases WHERE is_active ORDER BY test_id LOOP
        BEGIN
            EXECUTE rec.test_sql INTO v_actual;
            IF rec.test_type = 'ASSERT_ZERO' THEN
                IF v_actual = 0 THEN v_status := 'PASS'; v_pass := v_pass + 1;
                ELSE                 v_status := 'FAIL'; v_fail := v_fail + 1;
                END IF;
            ELSE
                v_status := 'INFO';
            END IF;

            INSERT INTO bl_cl.mta_test_results (test_id, test_name, test_group, actual_value, status, message)
            VALUES (rec.test_id, rec.test_name, rec.test_group, v_actual, v_status,
                    rec.test_type || ' -> ' || v_actual);
        EXCEPTION WHEN OTHERS THEN
            v_fail := v_fail + 1;
            INSERT INTO bl_cl.mta_test_results (test_id, test_name, test_group, actual_value, status, message)
            VALUES (rec.test_id, rec.test_name, rec.test_group, NULL, 'ERROR', SQLERRM);
        END;
    END LOOP;

    CALL bl_cl.p_log('run_all_tests', 'SUCCESS', v_pass + v_fail,
                     'Passed: ' || v_pass || ', Failed: ' || v_fail);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('run_all_tests', 'ERROR', NULL, SQLERRM);
END;
$$;
