WITH stg_dim_location__source AS (
    SELECT 
        DISTINCT *
    FROM {{source('glamira_src','raw_ip_location')}}
    WHERE status = 'success'
)

, stg_dim_location__rename AS (
    SELECT
        CAST(ip AS STRING) AS ip_address,
        CAST(country_short AS STRING) AS country_short_name,
        CAST(country_long AS STRING) AS country_long_name,
        CAST(region AS STRING) AS region_name,
        CAST(city AS STRING) AS city_name
    FROM stg_dim_location__source
    WHERE country_short <> '-' 
        AND country_short IS NOT NULL
)

, stg_dim_location__gen_key AS (
    SELECT
        FARM_FINGERPRINT(country_short_name ||region_name ||city_name) AS location_id,
        ip_address,
        country_short_name,
        country_long_name,
        region_name,
        city_name
    FROM stg_dim_location__rename
)

SELECT 
    *
FROM stg_dim_location__gen_key