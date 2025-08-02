{{ config(
    materialized='table'
) }}

WITH odds_data AS (
    SELECT * FROM {{ ref('src_odds') }}
),

fight_results AS (
    SELECT * FROM {{ ref('fct_fight_results') }}
),

parsed_odds AS (
    SELECT
        od.event_name,
        od.fight_matchup,
        od.fighter_name,
        
        -- Parse odds format (can be positive or negative)
        CASE
            WHEN od.betting_odds LIKE '+%' THEN TRY_TO_NUMBER(REPLACE(od.betting_odds, '+', ''))
            WHEN od.betting_odds LIKE '-%' THEN TRY_TO_NUMBER(od.betting_odds)
            ELSE TRY_TO_NUMBER(od.betting_odds)
        END as american_odds,
        
        od.bookmaker_name,
        od.odds_timestamp
    FROM odds_data od
),

odds_with_probability AS (
    SELECT
        po.*,
        
        -- Convert American odds to implied probability
        CASE
            WHEN po.american_odds < 0 
            THEN ABS(po.american_odds) / (ABS(po.american_odds) + 100.0)
            WHEN po.american_odds > 0 
            THEN 100.0 / (po.american_odds + 100.0)
            ELSE NULL
        END as implied_probability,
        
        -- Convert American odds to decimal odds
        CASE
            WHEN po.american_odds < 0 
            THEN 1 + (100.0 / ABS(po.american_odds))
            WHEN po.american_odds > 0 
            THEN 1 + (po.american_odds / 100.0)
            ELSE NULL
        END as decimal_odds
        
    FROM parsed_odds po
)

SELECT
    owp.event_name,
    fr.event_id,
    fr.event_date,
    owp.fight_matchup,
    fr.fight_id,
    owp.fighter_name,
    
    -- Determine if this fighter won
    CASE
        WHEN owp.fighter_name = fr.winner_name THEN TRUE
        WHEN owp.fighter_name = fr.loser_name THEN FALSE
        ELSE NULL
    END as is_winner,
    
    owp.american_odds,
    owp.decimal_odds,
    ROUND(owp.implied_probability, 4) as implied_probability,
    owp.bookmaker_name,
    owp.odds_timestamp,
    
    -- Calculate days before fight
    DATEDIFF(day, owp.odds_timestamp::DATE, fr.event_date) as days_before_fight,
    
    ROW_NUMBER() OVER (ORDER BY fr.event_date DESC, owp.fight_matchup, owp.fighter_name, owp.bookmaker_name, owp.odds_timestamp) as odds_id
    
FROM odds_with_probability owp
LEFT JOIN fight_results fr
    ON owp.event_name = fr.event_name
    AND (
        owp.fight_matchup = fr.bout
        OR REPLACE(owp.fight_matchup, ' ', '') = REPLACE(fr.bout, ' ', '')
    )
WHERE owp.american_odds IS NOT NULL