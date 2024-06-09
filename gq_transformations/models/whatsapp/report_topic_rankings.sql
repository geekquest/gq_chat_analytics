{{ config(materialized="view") }}

SELECT
    words.date_key AS date,
    dim_date.day_name AS day,
    dim_date.month_name AS month,
    dim_date.year,
    topic.topic,
    SUM(words.count) AS total_mentions,
    RANK() OVER (PARTITION BY words.date_key ORDER BY SUM(words.count) DESC) AS rank
FROM {{ ref("fact_word_count") }} AS words
INNER JOIN {{ ref("dim_topic") }} AS topic
    ON topic.topic = words.word
INNER JOIN {{ ref("dim_date") }} AS dim_date
    USING (date_key)
GROUP BY
    words.date_key,
    dim_date.day_name,
    dim_date.month_name,
    dim_date.year,
    topic.topic
