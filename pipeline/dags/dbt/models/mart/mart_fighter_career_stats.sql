{{ config(
    materialized='table'
) }}

WITH fighter_fight_stats AS (
    SELECT
        fs.fighter_name,
        fs.event_date,
        fs.is_winner,
        fs.finish_type,
        fs.round,
        
        -- Aggregate stats per fight
        SUM(fs.sig_str_landed) as total_sig_str_landed,
        SUM(fs.sig_str_attempted) as total_sig_str_attempted,
        SUM(fs.total_str_landed) as total_str_landed,
        SUM(fs.total_str_attempted) as total_str_attempted,
        SUM(fs.td_landed) as total_td_landed,
        SUM(fs.td_attempted) as total_td_attempted,
        SUM(fs.sub_attempts) as total_sub_attempts,
        SUM(fs.knockdowns) as total_knockdowns,
        SUM(fs.control_time_seconds) as total_control_time,
        MAX(fs.round) as final_round
        
    FROM {{ ref('fct_fight_stats') }} fs
    GROUP BY 1, 2, 3, 4, 5
),

career_aggregates AS (
    SELECT
        fighter_name,
        COUNT(DISTINCT event_date) as total_fights,
        SUM(CASE WHEN is_winner THEN 1 ELSE 0 END) as wins,
        SUM(CASE WHEN is_winner = FALSE THEN 1 ELSE 0 END) as losses,
        SUM(CASE WHEN is_winner IS NULL THEN 1 ELSE 0 END) as draws_nc,
        
        -- Win methods
        SUM(CASE WHEN is_winner AND finish_type = 'KO/TKO' THEN 1 ELSE 0 END) as ko_tko_wins,
        SUM(CASE WHEN is_winner AND finish_type = 'Submission' THEN 1 ELSE 0 END) as submission_wins,
        SUM(CASE WHEN is_winner AND finish_type = 'Decision' THEN 1 ELSE 0 END) as decision_wins,
        
        -- Loss methods
        SUM(CASE WHEN is_winner = FALSE AND finish_type = 'KO/TKO' THEN 1 ELSE 0 END) as ko_tko_losses,
        SUM(CASE WHEN is_winner = FALSE AND finish_type = 'Submission' THEN 1 ELSE 0 END) as submission_losses,
        SUM(CASE WHEN is_winner = FALSE AND finish_type = 'Decision' THEN 1 ELSE 0 END) as decision_losses,
        
        -- Strike statistics
        SUM(total_sig_str_landed) as career_sig_str_landed,
        SUM(total_sig_str_attempted) as career_sig_str_attempted,
        SUM(total_str_landed) as career_total_str_landed,
        SUM(total_str_attempted) as career_total_str_attempted,
        
        -- Takedown statistics
        SUM(total_td_landed) as career_td_landed,
        SUM(total_td_attempted) as career_td_attempted,
        SUM(total_sub_attempts) as career_sub_attempts,
        SUM(total_knockdowns) as career_knockdowns,
        
        -- Time statistics
        SUM(total_control_time) as career_control_time_seconds,
        SUM(final_round) as total_rounds_fought,
        
        -- Recent form (last 5 fights)
        SUM(CASE WHEN rn <= 5 AND is_winner THEN 1 ELSE 0 END) as last_5_wins,
        SUM(CASE WHEN rn <= 5 AND is_winner = FALSE THEN 1 ELSE 0 END) as last_5_losses,
        
        -- Fight frequency
        MIN(event_date) as first_fight_date,
        MAX(event_date) as last_fight_date,
        DATEDIFF(day, MIN(event_date), MAX(event_date)) as days_between_first_last_fight
        
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY fighter_name ORDER BY event_date DESC) as rn
        FROM fighter_fight_stats
    ) ffs
    GROUP BY fighter_name
)

SELECT
    ca.fighter_name,
    df.fighter_id,
    
    -- Basic record
    ca.total_fights,
    ca.wins,
    ca.losses,
    ca.draws_nc,
    ROUND(ca.wins::FLOAT / NULLIF(ca.wins + ca.losses, 0), 3) as win_rate,
    
    -- Finish statistics
    ca.ko_tko_wins,
    ca.submission_wins,
    ca.decision_wins,
    ca.ko_tko_losses,
    ca.submission_losses,
    ca.decision_losses,
    
    -- Finish rates
    ROUND(ca.ko_tko_wins::FLOAT / NULLIF(ca.wins, 0), 3) as ko_tko_win_rate,
    ROUND(ca.submission_wins::FLOAT / NULLIF(ca.wins, 0), 3) as submission_win_rate,
    ROUND(ca.decision_wins::FLOAT / NULLIF(ca.wins, 0), 3) as decision_win_rate,
    
    -- Strike statistics
    ca.career_sig_str_landed,
    ca.career_sig_str_attempted,
    ROUND(ca.career_sig_str_landed::FLOAT / NULLIF(ca.career_sig_str_attempted, 0), 3) as career_sig_str_accuracy,
    ROUND(ca.career_sig_str_landed::FLOAT / NULLIF(ca.total_rounds_fought, 0), 2) as sig_str_landed_per_round,
    
    ca.career_total_str_landed,
    ca.career_total_str_attempted,
    ROUND(ca.career_total_str_landed::FLOAT / NULLIF(ca.career_total_str_attempted, 0), 3) as career_total_str_accuracy,
    
    -- Takedown statistics
    ca.career_td_landed,
    ca.career_td_attempted,
    ROUND(ca.career_td_landed::FLOAT / NULLIF(ca.career_td_attempted, 0), 3) as career_td_accuracy,
    ROUND(ca.career_td_landed::FLOAT / NULLIF(ca.total_fights, 0), 2) as td_per_fight,
    
    -- Other statistics
    ca.career_sub_attempts,
    ROUND(ca.career_sub_attempts::FLOAT / NULLIF(ca.total_fights, 0), 2) as sub_attempts_per_fight,
    ca.career_knockdowns,
    ROUND(ca.career_knockdowns::FLOAT / NULLIF(ca.total_fights, 0), 2) as knockdowns_per_fight,
    
    -- Control time
    ca.career_control_time_seconds,
    ROUND(ca.career_control_time_seconds::FLOAT / NULLIF(ca.total_rounds_fought, 0), 2) as control_time_per_round,
    
    -- Recent form
    ca.last_5_wins,
    ca.last_5_losses,
    CONCAT(ca.last_5_wins, '-', ca.last_5_losses) as last_5_record,
    
    -- Activity
    ca.first_fight_date,
    ca.last_fight_date,
    ca.days_between_first_last_fight,
    ROUND(ca.days_between_first_last_fight::FLOAT / NULLIF(ca.total_fights - 1, 0), 1) as avg_days_between_fights,
    DATEDIFF(day, ca.last_fight_date, CURRENT_DATE()) as days_since_last_fight,
    
    -- Fighter attributes from dimension
    df.height_inches,
    df.weight_lbs,
    df.reach_inches,
    df.stance,
    df.age,
    df.slpm as profile_slpm,
    df.str_acc_pct as profile_str_acc,
    df.sapm as profile_sapm,
    df.str_def_pct as profile_str_def,
    df.td_avg as profile_td_avg,
    df.td_acc_pct as profile_td_acc,
    df.td_def_pct as profile_td_def,
    df.sub_avg as profile_sub_avg
    
FROM career_aggregates ca
LEFT JOIN {{ ref('dim_fighters') }} df
    ON ca.fighter_name = df.fighter_name