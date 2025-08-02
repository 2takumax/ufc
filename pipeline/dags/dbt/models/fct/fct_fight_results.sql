{{ config(
    materialized='table'
) }}

WITH fight_results AS (
    SELECT * FROM {{ ref('src_fight_results') }}
),

events AS (
    SELECT * FROM {{ ref('dim_events') }}
),

weight_classes AS (
    SELECT * FROM {{ ref('dim_weight_classes') }}
),

parsed_fights AS (
    SELECT
        fr.event_name,
        fr.bout,
        TRIM(SPLIT_PART(fr.bout, ' vs. ', 1)) as fighter1_name,
        TRIM(SPLIT_PART(fr.bout, ' vs. ', 2)) as fighter2_name,
        
        -- Parse outcome
        CASE
            WHEN fr.outcome = 'W/L' THEN 'fighter1_win'
            WHEN fr.outcome = 'L/W' THEN 'fighter2_win'
            WHEN fr.outcome = 'D/D' THEN 'draw'
            WHEN fr.outcome = 'NC/NC' THEN 'no_contest'
            ELSE 'unknown'
        END as fight_outcome,
        
        CASE
            WHEN fr.outcome = 'W/L' THEN fighter1_name
            WHEN fr.outcome = 'L/W' THEN fighter2_name
            ELSE NULL
        END as winner_name,
        
        CASE
            WHEN fr.outcome = 'W/L' THEN fighter2_name
            WHEN fr.outcome = 'L/W' THEN fighter1_name
            ELSE NULL
        END as loser_name,
        
        fr.weight_class,
        fr.method,
        
        -- Categorize finish method
        CASE
            WHEN LOWER(fr.method) LIKE '%ko%' OR LOWER(fr.method) LIKE '%tko%' THEN 'KO/TKO'
            WHEN LOWER(fr.method) LIKE '%submission%' THEN 'Submission'
            WHEN LOWER(fr.method) LIKE '%decision%' THEN 'Decision'
            WHEN LOWER(fr.method) LIKE '%dq%' THEN 'DQ'
            WHEN fr.outcome IN ('D/D', 'NC/NC') THEN 'Draw/NC'
            ELSE 'Other'
        END as finish_type,
        
        TRY_TO_NUMBER(fr.round) as round_number,
        fr.time,
        
        -- Calculate total fight time in seconds
        CASE
            WHEN fr.time IS NOT NULL AND CONTAINS(fr.time, ':')
            THEN ((TRY_TO_NUMBER(fr.round) - 1) * 300) + 
                 (TRY_TO_NUMBER(SPLIT_PART(fr.time, ':', 1)) * 60) + 
                 TRY_TO_NUMBER(SPLIT_PART(fr.time, ':', 2))
            ELSE NULL
        END as total_time_seconds,
        
        fr.time_format,
        fr.referee,
        fr.details,
        fr.fight_url
    FROM fight_results fr
)

SELECT
    pf.event_name,
    e.event_id,
    e.event_date,
    e.event_type,
    pf.bout,
    pf.fighter1_name,
    pf.fighter2_name,
    pf.fight_outcome,
    pf.winner_name,
    pf.loser_name,
    pf.weight_class,
    wc.weight_class_id,
    wc.weight_class_full_name,
    pf.method,
    pf.finish_type,
    pf.round_number,
    pf.time,
    pf.total_time_seconds,
    pf.time_format,
    pf.referee,
    pf.details,
    pf.fight_url,
    ROW_NUMBER() OVER (ORDER BY e.event_date DESC, pf.bout) as fight_id
FROM parsed_fights pf
LEFT JOIN events e
    ON pf.event_name = e.event_name
LEFT JOIN weight_classes wc
    ON LOWER(TRIM(pf.weight_class)) = LOWER(TRIM(wc.weight_class))