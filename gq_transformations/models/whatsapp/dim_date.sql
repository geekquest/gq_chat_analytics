{{ config(materialized="table") }}

SELECT
    CAST(date AS DATE) AS date_key,
    CAST(week_day AS INT) + 1 AS week_day,
    CAST(day_name AS VARCHAR(16)) AS day_name,
    CAST(month AS INT) AS month,
    CAST(month_name AS VARCHAR(16)) AS month_name,
    CAST(year AS INT) AS year,
    CAST(holiday AS VARCHAR(64)) AS holiday
FROM {{ ref("calendar") }}
