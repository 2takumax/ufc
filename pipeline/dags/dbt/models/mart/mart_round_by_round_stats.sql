{{ config(
    materialized='table'
) }}

WITH round_stats AS (
    SELECT
        fs.event_name,
        fs.event_id,
        fs.event_date,
        fs.bout,
        fs.fight_id,
        fs.round,
        fs.fighter_name,
        fs.opponent_name,
        fs.is_winner,
        fs.weight_class,
        fs.finish_type,
        
        -- Strike metrics
        fs.sig_str_landed,
        fs.sig_str_attempted,
        fs.sig_str_pct,
        fs.total_str_landed,
        fs.total_str_attempted,
        
        -- Takedown metrics
        fs.td_landed,
        fs.td_attempted,
        fs.td_pct,
        fs.sub_attempts,
        fs.reversals,
        fs.control_time_seconds,
        
        -- Strike locations
        fs.head_landed,
        fs.body_landed,
        fs.leg_landed,
        
        -- Strike positions
        fs.distance_landed,
        fs.clinch_landed,
        fs.ground_landed,
        
        -- Get opponent stats
        opp.sig_str_landed as opp_sig_str_landed,
        opp.total_str_landed as opp_total_str_landed,
        opp.td_landed as opp_td_landed,
        opp.control_time_seconds as opp_control_time_seconds
        
    FROM {{ ref('fct_fight_stats') }} fs
    LEFT JOIN {{ ref('fct_fight_stats') }} opp
        ON fs.event_name = opp.event_name
        AND fs.bout = opp.bout
        AND fs.round = opp.round
        AND fs.fighter_name = opp.opponent_name
),

round_aggregates AS (
    SELECT
        rs.*,
        
        -- Calculate round dominance metrics
        rs.sig_str_landed - COALESCE(rs.opp_sig_str_landed, 0) as sig_str_differential,
        rs.total_str_landed - COALESCE(rs.opp_total_str_landed, 0) as total_str_differential,
        rs.td_landed - COALESCE(rs.opp_td_landed, 0) as td_differential,
        rs.control_time_seconds - COALESCE(rs.opp_control_time_seconds, 0) as control_time_differential,
        
        -- Strike distribution percentages
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.head_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as head_strike_pct,
        
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.body_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as body_strike_pct,
        
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.leg_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as leg_strike_pct,
        
        -- Position distribution percentages
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.distance_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as distance_strike_pct,
        
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.clinch_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as clinch_strike_pct,
        
        CASE 
            WHEN rs.total_str_landed > 0 
            THEN ROUND(rs.ground_landed::FLOAT / rs.total_str_landed, 3)
            ELSE NULL
        END as ground_strike_pct,
        
        -- Round outcome prediction
        CASE
            WHEN rs.sig_str_differential > 10 AND rs.control_time_differential > 60 THEN 'Dominant'
            WHEN rs.sig_str_differential > 5 OR rs.control_time_differential > 30 THEN 'Clear'
            WHEN ABS(rs.sig_str_differential) <= 5 AND ABS(rs.control_time_differential) <= 30 THEN 'Close'
            ELSE 'Unclear'
        END as round_dominance_level
        
    FROM round_stats rs
),

cumulative_stats AS (
    SELECT
        *,
        
        -- Calculate cumulative stats through rounds
        SUM(sig_str_landed) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as cumulative_sig_str,
        SUM(total_str_landed) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as cumulative_total_str,
        SUM(td_landed) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as cumulative_td,
        SUM(control_time_seconds) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as cumulative_control_time,
        
        -- Running averages
        AVG(sig_str_landed) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as avg_sig_str_per_round,
        AVG(sig_str_pct) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as avg_sig_str_accuracy,
        
        -- Momentum indicators
        LAG(sig_str_differential, 1) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as prev_round_sig_str_diff,
        sig_str_differential - LAG(sig_str_differential, 1) OVER (PARTITION BY fight_id, fighter_name ORDER BY round) as momentum_change
        
    FROM round_aggregates
)

SELECT
    *,
    
    -- Fight progression indicators
    CASE
        WHEN round = 1 THEN 'Early'
        WHEN round <= 3 THEN 'Middle'
        ELSE 'Championship'
    END as fight_stage,
    
    -- Fatigue indicators (comparing to round 1)
    CASE
        WHEN round > 1 AND cumulative_sig_str > 0
        THEN sig_str_landed::FLOAT / (cumulative_sig_str::FLOAT / round)
        ELSE NULL
    END as output_vs_average,
    
    -- Momentum classification
    CASE
        WHEN momentum_change > 5 THEN 'Building'
        WHEN momentum_change < -5 THEN 'Fading'
        ELSE 'Stable'
    END as momentum_status
    
FROM cumulative_stats
ORDER BY event_date DESC, bout, round, fighter_name