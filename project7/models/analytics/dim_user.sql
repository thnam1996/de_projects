WITH dim_user__source AS (
    SELECT 
        DISTINCT user_id,
        email_address 
    FROM {{ref('stg_fact_sales_order_tt')}}
    WHERE user_id IS NOT NULL
)
, dim_user__null_handle AS (
    SELECT
        FARM_FINGERPRINT(CAST(user_id AS STRING) || CAST(email_address AS STRING)) AS sk_user_id,
        user_id,
        coalesce(email_address,"XNA") AS email_address
    FROM dim_user__source 
        
)
, dim_user__undefined_value AS (
    SELECT
        distinct
        sk_user_id,
        user_id,
        email_address
    FROM dim_user__null_handle
    
    UNION ALL

    SELECT 
        -1 AS sk_user_id,
        -1 AS user_id,
        'XNA' AS email_address
)

SELECT 
    *
FROM dim_user__undefined_value

