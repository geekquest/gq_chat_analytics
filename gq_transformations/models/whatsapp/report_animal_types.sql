{{ config(materialized="view") }}

WITH animal_type AS (
    SELECT
        dim_date.date_key AS date,
        dim_hour.animal_type,
        fact_chat.sender,
        COUNT(*) AS count,
        ROW_NUMBER() OVER (
            PARTITION BY
                dim_date.date_key,
                fact_chat.sender
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM {{ ref("fact_chat") }} AS fact_chat
    LEFT JOIN {{ ref("dim_hour") }} AS dim_hour
        USING (hour_key)
    LEFT JOIN {{ ref("dim_date") }} AS dim_date
        USING (date_key)
    WHERE
        dim_date.holiday IS NULL
        AND dim_date.day_name NOT IN ('Saturday', 'Sunday')
    GROUP BY
        dim_date.date_key,
        dim_hour.animal_type,
        fact_chat.sender
)
SELECT *
FROM animal_type
WHERE rank = 1
ORDER BY date DESC
