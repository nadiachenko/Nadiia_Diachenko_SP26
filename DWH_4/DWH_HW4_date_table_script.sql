
CREATE TABLE IF NOT EXISTS dim_time_day (
    date_key     INT NOT NULL,
    calendar_day DATE NOT NULL,
    day          INT NOT NULL,
    month        INT NOT NULL,
    quarter      INT NOT NULL,
    year         INT NOT NULL,
    CONSTRAINT pk_dim_time_day PRIMARY KEY (date_key));


INSERT INTO dim_time_day (
    date_key, 
    calendar_day, 
    day, 
    month, 
    quarter, 
    year)
SELECT 
    TO_CHAR(datum, 'YYYYMMDD')::INT AS date_key,
    datum::DATE                     AS calendar_day,
    EXTRACT(DAY FROM datum)::INT    AS day,
    EXTRACT(MONTH FROM datum)::INT  AS month,
    EXTRACT(QUARTER FROM datum)::INT AS quarter,
    EXTRACT(YEAR FROM datum)::INT   AS year
FROM 
    GENERATE_SERIES(
        '2025-01-01'::DATE, 
        '2026-12-31'::DATE, 
        '1 day'::INTERVAL) AS datum
ON CONFLICT (date_key) DO NOTHING; 

