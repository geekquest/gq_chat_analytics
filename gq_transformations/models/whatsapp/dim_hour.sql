{{ config(materialized="table") }}

SELECT
    range AS hour_key,
    CASE
        WHEN range >= 5 AND range < 9 THEN 'Early bird'
        WHEN (range >= 9 AND range < 11) OR (range >= 13 AND range < 17) THEN 'Slacker'
        WHEN (range >= 11 AND range < 13) THEN 'Anti-social'
        WHEN range >= 17 AND range < 20 THEN 'Loner'
        ELSE 'Nocturnal bird'
    END AS animal_type
FROM RANGE(24)
