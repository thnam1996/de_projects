WITH stg_fact_sales_order_tt__source AS (
    SELECT 
        DISTINCT *
    FROM {{source('glamira_src','raw_summary')}}
    WHERE collection = 'checkout_success'
)

/* 1. unnest cart_products */

, stg_fact_sales_order_tt__unnest AS (
    SELECT s.*, cp
    FROM stg_fact_sales_order_tt__source s
    CROSS JOIN UNNEST(s.cart_products) AS cp
)

, stg_fact_sales_order_tt__rename AS (
    SELECT
        SAFE_CAST(
        REGEXP_REPLACE(CAST(s.order_id AS STRING), r'\..*', '')
        AS INT64
        ) AS order_id,

        cp.price AS check,

        SAFE_CAST(
        REGEXP_REPLACE(CAST(cp.product_id AS STRING), r'\..*', '')
        AS INT64
        ) AS product_id,

        SAFE_CAST(
        REGEXP_REPLACE(CAST(s.user_id_db AS STRING), r'\..*', '')
        AS INT64
        ) AS user_id,

        SAFE_CAST(email_address AS STRING) AS email_address,

        SAFE_CAST(
        REGEXP_REPLACE(CAST(s.store_id AS STRING), r'\..*', '')
        AS INT64
        ) AS store_id,


        CAST(s.ip AS STRING) AS IP_address,
        -- local_time: STRING -> TIMESTAMP
        PARSE_TIMESTAMP(
          '%Y-%m-%d %H:%M:%S',
          REGEXP_REPLACE(
            CAST(s.local_time AS STRING),
            r'(\d{4}-\d{2}-\d{2}) (\d):',
            r'\1 0\2:'
          )
        ) AS local_time,

        -- time_stamp: epoch seconds -> TIMESTAMP
        TIMESTAMP_SECONDS(SAFE_CAST(s.time_stamp AS INT64)) AS time_stamp,        
        CAST(cp.amount  AS NUMERIC) AS quantity,

        SAFE_CAST(
        CASE
            -- 1) bỏ dấu '
            WHEN REGEXP_CONTAINS(cp.price, r"'") THEN
            REPLACE(cp.price, "'", "")

            -- 2) có dot ở cuối -> decimal dot -> remove comma, vd "1,000.32" -> "1000.32"
            WHEN REGEXP_CONTAINS(cp.price, r'\.\d+$') THEN
            REPLACE(cp.price, ',', '')

            -- 3) có dot + comma, và comma ở cuối -> remove dot, replace comma=dot,vd "4.300,32" -> "4300.32"
            WHEN REGEXP_CONTAINS(cp.price, r'\.\d+,\d+$') THEN 
            REPLACE(REPLACE(cp.price, '.', ''), ',', '.')

            -- 4) comma ở cuối với 1–2 decimal -> decimal comma, replace comma=dotm vd "2000,12" -> "2000.12"
            WHEN REGEXP_CONTAINS(cp.price, r',\d{1,2}$') THEN
            REPLACE(cp.price, ',', '.')

            -- 5) comma ở cuối các case còn lại -> thousand, remove comma, vd "2,000,000" -> "20000000"
            WHEN REGEXP_CONTAINS(cp.price, r',\d+$') THEN
            REPLACE(cp.price, ',', '')

            ELSE cp.price
        END
        AS NUMERIC
        ) AS price,
        CAST(coalesce(cp.currency, "XNA") AS STRING) AS currency
    FROM stg_fact_sales_order_tt__unnest s
    WHERE s.order_id IS NOT NULL
        AND cp.product_id IS NOT NULL
)

, stg_fact_sales_order_tt__gen_key AS (
    SELECT
        FARM_FINGERPRINT(CAST(Order_id AS STRING) || CAST(Product_id AS STRING)) AS sk_fact_sales,
        order_id,
        product_id,
        ip_address,
        user_id,
        email_address,
        store_id,
        local_time,
        time_stamp,
        UNIX_SECONDS(TIMESTAMP(DATE(time_stamp))) AS date_id,
        quantity,
        price,
        currency,
        check
    FROM stg_fact_sales_order_tt__rename
)

SELECT 
    *
FROM stg_fact_sales_order_tt__gen_key