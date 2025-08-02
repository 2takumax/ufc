{{ config(
    materialized='view'
) }}

-- This view creates features for upcoming fights that don't have results yet
-- It can be used for making predictions on future events

WITH upcoming_fights AS (
    -- This would typically come from a separate source table of scheduled fights
    -- For now, we'll create a template that can be adapted
    SELECT
        'UFC 300' as event_name,
        '2024-04-13'::DATE as event_date,
        'Fighter A vs. Fighter B' as bout,
        'Fighter A' as fighter1_name,
        'Fighter B' as fighter2_name,
        'Lightweight' as weight_class
    WHERE FALSE -- This prevents any rows from being created
),

fighter_stats AS (
    SELECT * FROM {{ ref('mart_fighter_career_stats') }}
),

weight_classes AS (
    SELECT * FROM {{ ref('dim_weight_classes') }}
),

matchup_features AS (
    SELECT
        uf.event_name,
        uf.event_date,
        uf.bout,
        uf.fighter1_name,
        uf.fighter2_name,
        uf.weight_class,
        wc.weight_class_id,
        
        -- Fighter 1 stats
        f1.total_fights as f1_total_fights,
        f1.wins as f1_wins,
        f1.losses as f1_losses,
        f1.win_rate as f1_win_rate,
        f1.ko_tko_win_rate as f1_ko_tko_win_rate,
        f1.submission_win_rate as f1_submission_win_rate,
        f1.decision_win_rate as f1_decision_win_rate,
        f1.career_sig_str_accuracy as f1_sig_str_accuracy,
        f1.sig_str_landed_per_round as f1_sig_str_per_round,
        f1.career_td_accuracy as f1_td_accuracy,
        f1.td_per_fight as f1_td_per_fight,
        f1.sub_attempts_per_fight as f1_sub_attempts_per_fight,
        f1.knockdowns_per_fight as f1_knockdowns_per_fight,
        f1.control_time_per_round as f1_control_time_per_round,
        f1.last_5_wins as f1_last_5_wins,
        f1.last_5_losses as f1_last_5_losses,
        f1.days_since_last_fight as f1_days_since_last_fight,
        f1.height_inches as f1_height,
        f1.weight_lbs as f1_weight,
        f1.reach_inches as f1_reach,
        f1.stance as f1_stance,
        f1.age as f1_age,
        
        -- Fighter 2 stats
        f2.total_fights as f2_total_fights,
        f2.wins as f2_wins,
        f2.losses as f2_losses,
        f2.win_rate as f2_win_rate,
        f2.ko_tko_win_rate as f2_ko_tko_win_rate,
        f2.submission_win_rate as f2_submission_win_rate,
        f2.decision_win_rate as f2_decision_win_rate,
        f2.career_sig_str_accuracy as f2_sig_str_accuracy,
        f2.sig_str_landed_per_round as f2_sig_str_per_round,
        f2.career_td_accuracy as f2_td_accuracy,
        f2.td_per_fight as f2_td_per_fight,
        f2.sub_attempts_per_fight as f2_sub_attempts_per_fight,
        f2.knockdowns_per_fight as f2_knockdowns_per_fight,
        f2.control_time_per_round as f2_control_time_per_round,
        f2.last_5_wins as f2_last_5_wins,
        f2.last_5_losses as f2_last_5_losses,
        f2.days_since_last_fight as f2_days_since_last_fight,
        f2.height_inches as f2_height,
        f2.weight_lbs as f2_weight,
        f2.reach_inches as f2_reach,
        f2.stance as f2_stance,
        f2.age as f2_age
        
    FROM upcoming_fights uf
    LEFT JOIN fighter_stats f1
        ON uf.fighter1_name = f1.fighter_name
    LEFT JOIN fighter_stats f2
        ON uf.fighter2_name = f2.fighter_name
    LEFT JOIN weight_classes wc
        ON LOWER(TRIM(uf.weight_class)) = LOWER(TRIM(wc.weight_class))
)

SELECT
    *,
    
    -- Calculate differentials (same as historical matchups)
    f1_wins - f2_wins as win_differential,
    f1_win_rate - f2_win_rate as win_rate_differential,
    f1_total_fights - f2_total_fights as experience_differential,
    
    -- Physical differentials
    f1_height - f2_height as height_differential,
    f1_reach - f2_reach as reach_differential,
    f1_age - f2_age as age_differential,
    
    -- Style differentials
    f1_sig_str_accuracy - f2_sig_str_accuracy as sig_str_accuracy_differential,
    f1_sig_str_per_round - f2_sig_str_per_round as sig_str_volume_differential,
    f1_td_accuracy - f2_td_accuracy as td_accuracy_differential,
    f1_td_per_fight - f2_td_per_fight as td_volume_differential,
    f1_sub_attempts_per_fight - f2_sub_attempts_per_fight as sub_attempts_differential,
    f1_knockdowns_per_fight - f2_knockdowns_per_fight as knockdown_differential,
    f1_control_time_per_round - f2_control_time_per_round as control_time_differential,
    
    -- Recent form differential
    f1_last_5_wins - f2_last_5_wins as recent_form_differential,
    
    -- Activity differential
    f2_days_since_last_fight - f1_days_since_last_fight as activity_differential,
    
    -- Stance matchup
    CASE
        WHEN f1_stance = f2_stance THEN 'Same'
        WHEN f1_stance = 'Orthodox' AND f2_stance = 'Southpaw' THEN 'Orthodox_vs_Southpaw'
        WHEN f1_stance = 'Southpaw' AND f2_stance = 'Orthodox' THEN 'Southpaw_vs_Orthodox'
        ELSE 'Other'
    END as stance_matchup,
    
    -- Prediction placeholders
    NULL::FLOAT as fighter1_win_probability,
    NULL::VARCHAR as predicted_method,
    NULL::INTEGER as predicted_round
    
FROM matchup_features