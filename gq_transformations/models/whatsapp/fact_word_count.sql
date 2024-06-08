{{ config(materialized="table") }}
WITH raw_words AS (
    SELECT
        CAST(timestamp AS DATE) AS date,
        sender,
        REGEXP_SPLIT_TO_TABLE(message, '\s+') AS word
    FROM {{ ref("whatsapp-chats") }}
),
cleaned_words AS (
    SELECT
        * EXCLUDE(word),
        REGEXP_REPLACE(LOWER(word), '[.,?!;:"''`+=<>|&%$~*^]+', '') AS word
    FROM raw_words
)
SELECT
    dim_date.date_key,
    words.sender,
    words.word,
    COUNT(*) AS count
FROM cleaned_words AS words
LEFT JOIN {{ ref("dim_date") }} AS dim_date
    ON dim_date.date_key = words.date
WHERE words.word NOT SIMILAR TO '^\s*$'
GROUP BY ALL
