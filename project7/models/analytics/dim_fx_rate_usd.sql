SELECT
    currency as from_currency,
    'USD' as to_currency,
    rate_to_usd,
    as_of_gmt

FROM {{ref('exchange_rate_usd')}}