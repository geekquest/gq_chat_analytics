{{ config(materialized="table") }}

SELECT
    range AS hour_key,
    CASE
        WHEN range >= 5 AND range < 9 THEN 'Early bird'
        WHEN (range >= 9 AND range < 12) OR (range >= 13 AND range < 17) THEN 'Slacker or unemployed'
        WHEN range >= 17 AND range < 22 THEN 'Likely lives alone'
        ELSE 'Nocturnal bird or vampire'
    END AS animal_type
FROM RANGE(24)
