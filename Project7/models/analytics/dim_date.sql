WITH dim_date__source AS (
    SELECT 
        DISTINCT DATE(time_stamp) AS full_date
    FROM {{ref('stg_fact_sales_order_tt')}}
    WHERE time_stamp IS NOT NULL
)
, dim_date__format AS (
    SELECT
        UNIX_SECONDS(TIMESTAMP(full_date)) AS date_id,
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