{{ config(
    materialized='ephemeral'
) }}

SELECT
    EVENT as event_name,
    BOUT as bout,
    OUTCOME as outcome,
    WEIGHTCLASS as weight_class,
    METHOD as method,
    ROUND as round,
    TIME as time,
    TIME_FORMAT as time_format,
    REFEREE as referee,
    DETAILS as details,
    URL as fight_url
FROM {{ source('ufc', 'fight_results') }}