WITH dim_store__source AS (
    SELECT 
        DISTINCT store_id,
    FROM {{ref('stg_fact_sales_order_tt')}}
    WHERE store_id IS NOT NULL
)
, dim_store__add_column AS (
    SELECT
        store_id,
        CONCAT("Store ",store_id) AS store_name
    FROM dim_store__source 
        
)

SELECT 
    *
FROM dim_store__add_column
ORDER BY 
        store_id
