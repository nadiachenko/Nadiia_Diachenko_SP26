CREATE TABLE IF NOT EXISTS bl_dm.dim_dates (
    date_key DATE NOT NULL,
    day INT NOT NULL,
    day_of_week VARCHAR NOT NULL,
    month INT NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    CONSTRAINT pk_dim_dates PRIMARY KEY (date_key)
);

INSERT INTO bl_dm.dim_dates (
    date_key,
    day,
    day_of_week,
    month,
    quarter,
    year
)
SELECT
    datum::DATE AS date_key,
    EXTRACT(DAY FROM datum)::INT AS day,
    TRIM(TO_CHAR(datum, 'Day')) AS day_of_week,
    EXTRACT(MONTH FROM datum)::INT AS month,
    EXTRACT(QUARTER FROM datum)::INT AS quarter,
    EXTRACT(YEAR FROM datum)::INT AS year
FROM
    GENERATE_SERIES(
        '2020-01-01'::DATE,
        '2030-12-31'::DATE,
        '1 day'::INTERVAL
    ) AS datum
ON CONFLICT (date_key) DO NOTHING;
