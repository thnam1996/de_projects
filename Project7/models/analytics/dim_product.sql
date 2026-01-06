WITH dim_product__source AS (
    SELECT *
    FROM {{ref('stg_dim_product')}}
)
, dim_product__null_handle AS (
    SELECT
        product_id,
        coalesce(product_name,'XNA') AS product_name,
        coalesce(product_url,'XNA') AS product_url,
        coalesce(sku,'XNA') AS sku,
        coalesce(product_type,'XNA') AS product_type,
        coalesce(category_name,'XNA') AS category_name,
        coalesce(collection_name,'XNA') AS collection_name,
        min_price,
        max_price
    FROM dim_product__source 
)
, dim_product__undefined_value AS (
    SELECT DISTINCT
        product_id,
        product_name,
        product_url,
        sku,
        product_type,
        category_name,
        collection_name,
        min_price,
        max_price
    FROM dim_product__null_handle
    
    UNION ALL

    SELECT 
        -1 AS product_id,
        'XNA' AS product_name,
        'XNA' AS product_url,
        'XNA' AS sku,
        'XNA' AS product_type,
        'XNA' AS category_name,
        'XNA' AS collection_name,
        CAST(NULL AS NUMERIC) AS min_price,
        CAST(NULL AS NUMERIC) AS max_price
)

SELECT *
FROM dim_product__undefined_value 
