-------Task 1-------

WITH sales_per_channel AS (
    SELECT co.country_region,
        ch.channel_desc,
        EXTRACT(YEAR FROM s.time_id) AS calendar_year,
        SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON co.country_id = cu.country_id
    JOIN sh.channels  ch ON s.channel_id = ch.channel_id
    WHERE co.country_region IN ('Americas', 'Asia', 'Europe')
      AND EXTRACT(YEAR FROM s.time_id) IN (1999, 2000, 2001)
    GROUP BY
        co.country_region,
        ch.channel_desc,
        EXTRACT(YEAR FROM s.time_id)),
with_pct AS (
    SELECT
        country_region,
        channel_desc,
        calendar_year,
        amount_sold,
        ROUND( amount_sold / SUM(amount_sold) OVER (PARTITION BY calendar_year, country_region) * 100, 2) AS pct_by_channels
    FROM sales_per_channel),
with_prev AS (
    SELECT
        country_region,
        channel_desc,
        calendar_year,
        amount_sold,
        pct_by_channels,
        SUM(pct_by_channels) OVER (PARTITION BY country_region, channel_desc ORDER BY calendar_year RANGE BETWEEN 1 PRECEDING AND 1 PRECEDING) AS pct_previous_period
    FROM with_pct)
SELECT
    country_region,
    channel_desc,
    calendar_year,
    amount_sold,
    pct_by_channels AS "% BY CHANNELS",
    pct_previous_period AS "% PREVIOUS PERIOD",
    ROUND(pct_by_channels - pct_previous_period, 2) AS "% DIFF"
FROM with_prev
ORDER BY country_region ASC, calendar_year ASC, channel_desc ASC;

-------Task 2-------

WITH daily_sales AS (
    SELECT
        EXTRACT(WEEK FROM s.time_id) AS calendar_week_number,
        s.time_id AS sale_date,
        TRIM(TO_CHAR(s.time_id, 'Day')) AS day_name,
        SUM(s.amount_sold) AS sales
    FROM sh.sales s
    WHERE EXTRACT(WEEK FROM s.time_id) BETWEEN 48 AND 52 
      AND EXTRACT(YEAR FROM s.time_id) = 1999 
    GROUP BY EXTRACT(WEEK FROM s.time_id), s.time_id, TRIM(TO_CHAR(s.time_id, 'Day'))),
with_avg AS (
    SELECT
        calendar_week_number,
        sale_date,
        day_name,
        sales,
        SUM(sales) OVER (PARTITION BY calendar_week_number ORDER BY sale_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum,
        CASE WHEN day_name = 'Monday'
            THEN ROUND(AVG(sales) OVER (ORDER BY sale_date RANGE BETWEEN INTERVAL '2' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING),2)
            WHEN day_name = 'Friday'
            THEN ROUND(AVG(sales) OVER (ORDER BY sale_date RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND INTERVAL '2' DAY FOLLOWING),2)
            ELSE ROUND(AVG(sales) OVER (ORDER BY sale_date RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING),2)
        END AS centered_3_day_avg
    FROM daily_sales)
SELECT calendar_week_number,
    sale_date,
    day_name,
    sales,
    cum_sum,
    centered_3_day_avg
FROM with_avg
WHERE calendar_week_number BETWEEN 49 AND 51
ORDER BY sale_date ASC;


-------Task 3-------

--ROWs - calculating running total. It is selected as we do not 'logical' calculations. As the query is grouped by date, there is no need to apply other functions and 'physical' rows sum may be calculated.

WITH daily_sales AS (
SELECT co.country_region,
	s.time_id,
    SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON co.country_id = cu.country_id
    WHERE EXTRACT(YEAR FROM s.time_id) = 2000
    GROUP BY co.country_region, s.time_id)
SELECT country_region,
	time_id,
    SUM(amount_sold) over (PARTITION BY country_region ORDER BY time_id 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_amount_sold
FROM daily_sales
ORDER BY country_region, time_id;   
 
---RANGE - calculating 7-day rolling total. It is selected to display the total for the last 7 days. RANGE is selected because it takes into account only the required dates, even with sales gaps within the declared range.


WITH daily_sales AS (
SELECT co.country_region,
	s.time_id,
    SUM(s.amount_sold) AS amount_sold
    FROM sh.sales s
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON co.country_id = cu.country_id
    WHERE EXTRACT(YEAR FROM s.time_id) = 2000
    GROUP BY co.country_region, s.time_id)
SELECT country_region,
	time_id,
    SUM(amount_sold) OVER (
    PARTITION BY country_region
    ORDER BY time_id
    RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW
) AS rolling_7_day_sum
FROM daily_sales
ORDER BY country_region, time_id; 


--GROUPS -- calculating average sales. It is selected because the calculations are required regardless of the dates, so it does not matter whether sales occurred on specific days — for example, if the business did not make sales on particular dates.

WITH daily_sales AS (
SELECT co.country_region,
	s.time_id,
    AVG(s.amount_sold) AS amount_sold
    FROM sh.sales s
    JOIN sh.customers cu ON s.cust_id = cu.cust_id
    JOIN sh.countries co ON co.country_id = cu.country_id
    WHERE EXTRACT(YEAR FROM s.time_id) = 2000
    GROUP BY co.country_region, s.time_id)
SELECT country_region,
	time_id,
    AVG(amount_sold) OVER (
    PARTITION BY country_region
    ORDER BY time_id
    GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS 3_day_avg
FROM daily_sales
ORDER BY country_region, time_id; 