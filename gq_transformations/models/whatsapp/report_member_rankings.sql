{{ config(materialized="view") }}

WITH member_rankings AS (
    SELECT
        dim_date.date_key AS date,
        dim_date.day_name AS day,
        dim_date.month_name AS month,
        dim_date.year,
        dim_date.holiday IS NOT NULL AS is_holiday,
        dim_date.holiday AS holiday_name,
        fact_chat.sender,
        MIN(fact_chat.timestamp) AS active_from,
        MAX(fact_chat.timestamp) AS active_to,
        COUNT(*) AS total_messages,
        RANK() OVER (PARTITION BY dim_date.date_key ORDER BY COUNT(*) DESC) AS rank
    FROM {{ ref("fact_chat") }} AS fact_chat
    LEFT JOIN {{ ref("dim_date") }} AS dim_date
        ON dim_date.date_key = fact_chat.date_key
    GROUP BY
        dim_date.date_key,
        dim_date.day_name,
        dim_date.month_name,
        dim_date.year,
        dim_date.holiday,
        fact_chat.sender
)
SELECT
    *
FROM member_rankings
