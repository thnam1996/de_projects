{{
  config(
    materialized='table'
  )
}}

WITH fct AS (
  SELECT
    order_id,
    date_id,
    location_id,
    line_total_usd,
    sk_user_id
  FROM {{ ref('fact_sales_order_tt') }}
  WHERE order_id IS NOT NULL
),

d AS (
  SELECT
    date_id,
    full_date,
    year_month
  FROM {{ ref('dim_date') }}
),

l AS (
  SELECT
    location_id,
    country_long_name
  FROM {{ ref('dim_location') }}
)

SELECT
  d.year_month,
  d.full_date AS date,
  COALESCE(l.country_long_name, 'UNKNOWN') AS country,
  COUNT(DISTINCT fct.order_id)        AS orders,
  ROUND(SUM(fct.line_total_usd), 2)   AS revenue,
  COUNT(DISTINCT fct.sk_user_id)      AS total_users
FROM fct
LEFT JOIN d
  ON fct.date_id = d.date_id
LEFT JOIN l
  ON fct.location_id = l.location_id
WHERE d.full_date IS NOT NULL
GROUP BY 1,2,3
ORDER BY 2,1,3
