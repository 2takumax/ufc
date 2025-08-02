{{ config(
    materialized='ephemeral'
) }}

SELECT
    EVENT as event_name,
    FIGHT as fight_matchup,
    FIGHTER as fighter_name,
    ODDS as betting_odds,
    BOOKMAKER as bookmaker_name,
    TIMESTAMP as odds_timestamp
FROM {{ source('ufc', 'odds') }}