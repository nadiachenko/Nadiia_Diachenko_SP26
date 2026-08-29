UPDATE bl_3nf.ce_customers_scd
SET customer_segment = 'VIP',         
    update_dt = CURRENT_DATE
WHERE customer_id = '1252'   
  AND is_active = 'Y';


select * from bl_3nf.ce_customers_scd ccs WHERE customer_id = '1252'

CALL bl_cl.load_dim_customers_scd_incr();

SELECT customer_surr_id, customer_src_id, customer_segment,
       is_active, start_dt, end_dt
FROM bl_dm.dim_customers_scd
WHERE customer_src_id = '1252'
ORDER BY start_dt;

SELECT procedure_name, rows_affected, log_message
FROM bl_cl.mta_load_logs
WHERE procedure_name = 'load_dim_customers_scd_incr'
ORDER BY log_id DESC LIMIT 3;