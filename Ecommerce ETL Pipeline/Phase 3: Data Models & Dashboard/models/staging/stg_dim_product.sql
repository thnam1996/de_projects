WITH stg_dim_product__source AS (
    SELECT 
        DISTINCT *
    FROM {{source('glamira_src','raw_product')}}
)

, stg_dim_product__rename AS (
    SELECT
        SAFE_CAST(product_id AS INT64) AS product_id,
        CAST(name AS STRING) AS product_name,
        CAST(url AS STRING) AS product_url,
        CAST(sku AS STRING) AS sku,
        CAST(product_type AS STRING) AS product_type,
        CAST(category_name AS STRING) AS category_name,
        CAST(collection AS STRING) AS collection_name,
        SAFE_CAST(min_price AS NUMERIC) AS min_price,
        SAFE_CAST(max_price AS NUMERIC) AS max_price
    FROM stg_dim_product__source
    WHERE product_id IS NOT NULL
)

SELECT 
    *
FROM stg_dim_product__rename 
