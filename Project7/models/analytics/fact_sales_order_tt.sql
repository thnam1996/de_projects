WITH fact_sales_order__source AS (
    SELECT *
    FROM {{ref('stg_fact_sales_order_tt')}}
)

SELECT 
    p1.sk_fact_sales,
    p1.order_id,
    coalesce(p1.product_id,-1) as product_id,
    p3.date_id, 
    coalesce(p2.location_id,-1) as location_id,
    p1.ip_address,
    coalesce(p1.user_id,-1) as user_id,
    p1.store_id,
    p1.local_time,
    p1.time_stamp,
    p1.quantity,
    p1.price,
    currency,
    round(p1.price*p1.quantity,2) AS line_total
    
FROM fact_sales_order__source p1
LEFT JOIN {{ref('stg_dim_location')}} AS p2
    ON p1.ip_address = p2.ip_address
LEFT JOIN {{ref('dim_date')}} AS P3
    ON p1.date_id = p3.date_id

  