----------TASK 1-----------

/* Finding top 5 customers:
 * the subquery to find a total sum per customer/channel is done initially
 * the query to select required data and partition over channel is added
 * finding top 5 customers - the ROW_NUMBER()is selected to give the customers numbers, avoiding ties
 * the query 'framed' in CTE to select custommers with rank<=5
 * 
 * KPI calculation:
 * the line to sum channel totals is added to the CTE
 * the mathematical calculation to get the customer percentage is performed 
 */

WITH channel_initial_calc AS (
    SELECT channel_desc, 
        cust_last_name, 
        cust_first_name, 
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY channel_desc ORDER BY total_amount DESC) as sales_rank,
        SUM(total_amount) OVER (PARTITION BY channel_desc) as channel_total
    FROM (SELECT ch.channel_desc, cu.cust_last_name, cu.cust_first_name, SUM(s.amount_sold) as total_amount
        FROM sh.sales s
        JOIN sh.customers cu ON s.cust_id = cu.cust_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
        GROUP BY ch.channel_desc, cu.cust_last_name, cu.cust_first_name) as sales_sum)
SELECT channel_desc, 
    cust_last_name, 
    cust_first_name, 
    ROUND(total_amount, 2) as amount_sold,
    CONCAT(ROUND((total_amount / channel_total) * 100, 4), ' %') as sales_percentage
FROM channel_initial_calc 
WHERE sales_rank <= 5
ORDER BY channel_desc, total_amount DESC;

----------TASK 2-----------

/* Firstly, the query to find the sum of sales grouped by category, year, and region is created by joining the corresponding tables. After that, the extension to enable the tablefunc module is installed, and the crosstab function is used: added division into 4 quaters and year_sum.*/

SELECT *,
(q1 + q2 + q3 + q4) AS YEAR_SUM
FROM crosstab('SELECT p.prod_name::text,
EXTRACT(QUARTER FROM s.time_id) AS sales_quarter,
ROUND(SUM(s.amount_sold), 2) AS product_sales
FROM sh.sales s
        JOIN sh.products p ON p.prod_id = s.prod_id
        JOIN sh.customers cu ON s.cust_id = cu.cust_id
        JOIN sh.countries co ON co.country_id = cu.country_id
WHERE p.prod_category = ''Photo'' AND co.country_region = ''Asia'' AND EXTRACT(YEAR FROM s.time_id) = 2000
GROUP BY p.prod_name, sales_quarter') AS 
ct(prod_name text, q1 numeric, 
    q2 numeric, 
    q3 numeric, 
    q4 numeric)
ORDER BY year_sum DESC;

----------TASK 3-----------

/* The query to select total amount per customer is written. To rank the customers the initial query is framed in CTE
 * As in 1st task ROW_NUMBER() is chosen to have 300 customers strictly and disregard ties.
 */
WITH cte AS (
    SELECT 
        ch.channel_desc, 
        c.cust_id, 
        c.cust_last_name, 
        c.cust_first_name,
        ROUND(SUM(s.amount_sold), 2) AS amount_sold, 
        EXTRACT(YEAR FROM s.time_id) AS year,
        ROW_NUMBER() OVER (
            PARTITION BY ch.channel_desc, EXTRACT(YEAR FROM s.time_id) 
            ORDER BY SUM(s.amount_sold) DESC
        ) AS customer_rank
    FROM sh.sales s
    JOIN sh.customers c ON s.cust_id = c.cust_id
    JOIN sh.channels ch ON s.channel_id = ch.channel_id
    WHERE EXTRACT(YEAR FROM s.time_id) IN (1998, 1999, 2001)
    GROUP BY 
        ch.channel_desc, 
        c.cust_id, 
        c.cust_last_name, 
        c.cust_first_name, 
        EXTRACT(YEAR FROM s.time_id))
SELECT 
    channel_desc, 
    cust_id, 
    cust_last_name, 
    cust_first_name, 
    amount_sold, 
    customer_rank,
    year
FROM cte
WHERE customer_rank <= 300
ORDER BY 
    year ASC, 
    channel_desc ASC, 
    customer_rank ASC;

----------TASK 4-----------

/*Generally, it seems that a window function is not necessary here, nor is crosstab pivoting. The result can be achieved with GROUP BY and joins. The current query looks redundant and heavy, especially due to the DISTINCT keyword that was required to meet the requirement of using window functions. 
 * 
 * The initial query ('base') is written to obtain the required data, and then an outer query is added to pivot the results. 
 */

 SELECT DISTINCT
        calendar_month_desc,
        prod_category,
        SUM(CASE WHEN country_region = 'Americas' THEN amount_sold END)
            OVER (PARTITION BY calendar_month_desc, prod_category) AS "Americas SALES",
        SUM(CASE WHEN country_region = 'Europe' THEN amount_sold END)
            OVER (PARTITION BY calendar_month_desc, prod_category)   AS "Europe SALES"
    FROM (SELECT
            TO_CHAR(DATE_TRUNC('month', s.time_id), 'YYYY-MM') AS calendar_month_desc,
            p.prod_category,
            co.country_region,
            SUM(s.amount_sold) AS amount_sold
        FROM sh.sales s
        JOIN sh.products  p  ON p.prod_id = s.prod_id
        JOIN sh.customers cu ON s.cust_id = cu.cust_id
        JOIN sh.countries co ON co.country_id = cu.country_id
        WHERE co.country_region IN ('Americas', 'Europe')
          AND TO_CHAR(DATE_TRUNC('month', s.time_id), 'YYYY-MM') IN ('2000-01', '2000-02', '2000-03')
        GROUP BY calendar_month_desc, p.prod_category, co.country_region) base
ORDER BY calendar_month_desc, prod_category;
