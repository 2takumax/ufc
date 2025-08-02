{{ config(
    materialized='ephemeral'
) }}

SELECT
    EVENT as event_name,
    FIGHT as fight_matchup,
    URL as fight_url
FROM {{ source('ufc', 'fight_details') }}