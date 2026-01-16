WITH dim_date__source AS (
    SELECT full_date
    FROM unnest(
        GENERATE_DATE_ARRAY(
            DATE '2020-01-01',
            DATE '2025-12-31',
            INTERVAL 1 DAY
        )) AS full_date
)
, dim_date__format AS (
    SELECT
        CAST(FORMAT_DATE('%Y%m%d',full_date) AS INT64) AS date_id,
        full_date,
        FORMAT_DATE('%A', full_date) AS day_of_week,
        CASE
            WHEN FORMAT_DATE('%A', full_date) = 'Saturday' 
                OR FORMAT_DATE('%A', full_date) = 'Sunday' THEN TRUE
            ELSE FALSE
        END AS is_weekend,
        FORMAT_DATE('%d', full_date) AS day_of_month,
        FORMAT_DATE('%Y-%m', full_date) AS year_month,
        FORMAT_DATE('%m', full_date) AS month,
        FORMAT_DATE('%j', full_date) AS day_of_year,
        FORMAT_DATE('%W', full_date) AS week_of_year,
        FORMAT_DATE('%Q', full_date) AS quarter_of_year,
        FORMAT_DATE('%Y', full_date) AS year,
        FORMAT_DATE('%y', full_date) AS year_number
    FROM dim_date__source
    ORDER BY 
        full_date    
)

SELECT 
    *
FROM dim_date__format