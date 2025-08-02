{{ config(
    materialized='ephemeral'
) }}

WITH odds_unpivoted AS (
    -- Unpivot the odds data to have one row per fighter
    SELECT
        EVENT as event_name,
        CONCAT(FIGHTER1, ' vs. ', FIGHTER2) as fight_matchup,
        FIGHTER1 as fighter_name,
        FIGHTER1_ODDS as betting_odds,
        'BestFightOdds' as bookmaker_name,
        TIMESTAMP as odds_timestamp
    FROM {{ source('ufc', 'odds') }}
    
    UNION ALL
    
    SELECT
        EVENT as event_name,
        CONCAT(FIGHTER1, ' vs. ', FIGHTER2) as fight_matchup,
        FIGHTER2 as fighter_name,
        FIGHTER2_ODDS as betting_odds,
        'BestFightOdds' as bookmaker_name,
        TIMESTAMP as odds_timestamp
    FROM {{ source('ufc', 'odds') }}
)

SELECT * FROM odds_unpivoted