SELECT 
    order_id,
    product_id,
    count(*) AS cnt    
FROM {{ref('fact_sales_order_tt')}}
WHERE order_id IS NOT NULL
AND product_id IS NOT NULL
GROUP BY 1, 2
HAVING COUNT(*) > 1