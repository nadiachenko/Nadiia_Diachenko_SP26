CREATE OR REPLACE PROCEDURE bl_cl.prune_fct_partitions(p_keep_months INT DEFAULT 3)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anchor  DATE;
    v_cutoff  DATE;
    v_dropped INT := 0;
    rec       RECORD;
BEGIN
    SELECT DATE_TRUNC('month', MAX(order_dt))::DATE INTO v_anchor
    FROM bl_3nf.ce_orders;
    v_cutoff := (v_anchor - ((p_keep_months - 1) || ' month')::INTERVAL)::DATE;
 
    FOR rec IN
        SELECT c.relname AS part_name
        FROM pg_inherits i
        JOIN pg_class c ON c.oid = i.inhrelid
        WHERE i.inhparent = 'bl_dm.fct_orders_dd'::regclass
          AND c.relname ~ '^fct_orders_dd_\d{4}_\d{2}$'
          AND TO_DATE(RIGHT(c.relname, 7), 'YYYY_MM') < v_cutoff
    LOOP
        EXECUTE format('ALTER TABLE bl_dm.fct_orders_dd DETACH PARTITION bl_dm.%I', rec.part_name);
        EXECUTE format('DROP TABLE bl_dm.%I', rec.part_name);
        v_dropped := v_dropped + 1;
    END LOOP;
    CALL bl_cl.p_log('prune_fct_partitions', 'SUCCESS', v_dropped,
                     'Detached/dropped ' || v_dropped || ' partition(s) older than ' || v_cutoff);
EXCEPTION WHEN OTHERS THEN
    CALL bl_cl.p_log('prune_fct_partitions', 'ERROR', NULL, SQLERRM);
END;
$$;
