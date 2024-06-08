{{ config(materialized="table") }}

SELECT
    dim_date.date_key,
    dim_hour.hour_key,
    chat.sender,
    chat.message,
    CAST(chat.timestamp AS DATETIME) AS timestamp
FROM {{ ref("whatsapp-chats") }} AS chat
LEFT JOIN {{ ref("dim_date") }} AS dim_date
    ON dim_date.date_key = CAST(chat.timestamp AS DATE)
LEFT JOIN {{ ref("dim_hour") }} AS dim_hour
    ON dim_hour.hour_key = DATE_PART('hour', CAST(chat.timestamp AS DATETIME))
