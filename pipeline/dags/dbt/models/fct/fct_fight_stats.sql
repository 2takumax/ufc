{{ config(
    materialized='table'
) }}

WITH fight_stats AS (
    SELECT * FROM {{ ref('src_fight_stats') }}
),

fight_results AS (
    SELECT * FROM {{ ref('fct_fight_results') }}
),

parsed_stats AS (
    SELECT
        fs.event_name,
        fs.bout,
        fs.round,
        fs.fighter_name,
        
        -- Parse strike statistics
        TRY_TO_NUMBER(fs.knockdowns) as knockdowns,
        
        CASE 
            WHEN CONTAINS(fs.sig_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.sig_strikes, ' of ', 1))
            ELSE NULL
        END as sig_str_landed,
        
        CASE 
            WHEN CONTAINS(fs.sig_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.sig_strikes, ' of ', 2))
            ELSE NULL
        END as sig_str_attempted,
        
        TRY_TO_NUMBER(REPLACE(fs.sig_strikes_pct, '%', '')) as sig_str_pct,
        
        CASE 
            WHEN CONTAINS(fs.total_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.total_strikes, ' of ', 1))
            ELSE NULL
        END as total_str_landed,
        
        CASE 
            WHEN CONTAINS(fs.total_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.total_strikes, ' of ', 2))
            ELSE NULL
        END as total_str_attempted,
        
        -- Parse takedown statistics
        CASE 
            WHEN CONTAINS(fs.takedowns, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.takedowns, ' of ', 1))
            ELSE NULL
        END as td_landed,
        
        CASE 
            WHEN CONTAINS(fs.takedowns, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.takedowns, ' of ', 2))
            ELSE NULL
        END as td_attempted,
        
        TRY_TO_NUMBER(REPLACE(fs.takedown_pct, '%', '')) as td_pct,
        
        TRY_TO_NUMBER(fs.submission_attempts) as sub_attempts,
        TRY_TO_NUMBER(fs.reversals) as reversals,
        
        -- Parse control time
        CASE 
            WHEN fs.control_time != '--' AND CONTAINS(fs.control_time, ':')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.control_time, ':', 1)) * 60 + 
                 TRY_TO_NUMBER(SPLIT_PART(fs.control_time, ':', 2))
            ELSE NULL
        END as control_time_seconds,
        
        -- Parse strike locations
        CASE 
            WHEN CONTAINS(fs.head_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.head_strikes, ' of ', 1))
            ELSE NULL
        END as head_landed,
        
        CASE 
            WHEN CONTAINS(fs.head_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.head_strikes, ' of ', 2))
            ELSE NULL
        END as head_attempted,
        
        CASE 
            WHEN CONTAINS(fs.body_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.body_strikes, ' of ', 1))
            ELSE NULL
        END as body_landed,
        
        CASE 
            WHEN CONTAINS(fs.body_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.body_strikes, ' of ', 2))
            ELSE NULL
        END as body_attempted,
        
        CASE 
            WHEN CONTAINS(fs.leg_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.leg_strikes, ' of ', 1))
            ELSE NULL
        END as leg_landed,
        
        CASE 
            WHEN CONTAINS(fs.leg_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.leg_strikes, ' of ', 2))
            ELSE NULL
        END as leg_attempted,
        
        -- Parse strike positions
        CASE 
            WHEN CONTAINS(fs.distance_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.distance_strikes, ' of ', 1))
            ELSE NULL
        END as distance_landed,
        
        CASE 
            WHEN CONTAINS(fs.distance_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.distance_strikes, ' of ', 2))
            ELSE NULL
        END as distance_attempted,
        
        CASE 
            WHEN CONTAINS(fs.clinch_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.clinch_strikes, ' of ', 1))
            ELSE NULL
        END as clinch_landed,
        
        CASE 
            WHEN CONTAINS(fs.clinch_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.clinch_strikes, ' of ', 2))
            ELSE NULL
        END as clinch_attempted,
        
        CASE 
            WHEN CONTAINS(fs.ground_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.ground_strikes, ' of ', 1))
            ELSE NULL
        END as ground_landed,
        
        CASE 
            WHEN CONTAINS(fs.ground_strikes, ' of ')
            THEN TRY_TO_NUMBER(SPLIT_PART(fs.ground_strikes, ' of ', 2))
            ELSE NULL
        END as ground_attempted
        
    FROM fight_stats fs
)

SELECT
    ps.event_name,
    fr.event_id,
    fr.event_date,
    ps.bout,
    fr.fight_id,
    ps.round,
    ps.fighter_name,
    
    -- Determine opponent name
    CASE
        WHEN ps.fighter_name = fr.fighter1_name THEN fr.fighter2_name
        WHEN ps.fighter_name = fr.fighter2_name THEN fr.fighter1_name
        ELSE NULL
    END as opponent_name,
    
    -- Determine if this fighter won
    CASE
        WHEN ps.fighter_name = fr.winner_name THEN TRUE
        WHEN ps.fighter_name = fr.loser_name THEN FALSE
        ELSE NULL
    END as is_winner,
    
    fr.weight_class,
    fr.weight_class_id,
    fr.finish_type,
    
    -- Strike statistics
    ps.knockdowns,
    ps.sig_str_landed,
    ps.sig_str_attempted,
    ps.sig_str_pct,
    ps.total_str_landed,
    ps.total_str_attempted,
    
    -- Calculate additional strike metrics
    CASE 
        WHEN ps.total_str_attempted > 0 
        THEN ROUND(ps.total_str_landed::FLOAT / ps.total_str_attempted * 100, 1)
        ELSE NULL
    END as total_str_pct,
    
    -- Takedown statistics
    ps.td_landed,
    ps.td_attempted,
    ps.td_pct,
    ps.sub_attempts,
    ps.reversals,
    ps.control_time_seconds,
    
    -- Strike location statistics
    ps.head_landed,
    ps.head_attempted,
    ps.body_landed,
    ps.body_attempted,
    ps.leg_landed,
    ps.leg_attempted,
    
    -- Strike position statistics
    ps.distance_landed,
    ps.distance_attempted,
    ps.clinch_landed,
    ps.clinch_attempted,
    ps.ground_landed,
    ps.ground_attempted,
    
    ROW_NUMBER() OVER (ORDER BY fr.event_date DESC, ps.bout, ps.round, ps.fighter_name) as fight_stat_id
    
FROM parsed_stats ps
LEFT JOIN fight_results fr
    ON ps.event_name = fr.event_name
    AND ps.bout = fr.bout