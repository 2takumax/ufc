{{ config(
    materialized='ephemeral'
) }}

SELECT
    EVENT as event_name,
    BOUT as bout,
    ROUND as round,
    FIGHTER as fighter_name,
    KD as knockdowns,
    SIG_STR as sig_strikes,
    SIG_STR_RATE as sig_strikes_pct,
    TOTAL_STR as total_strikes,
    TD as takedowns,
    TD_RATE as takedown_pct,
    SUB_ATT as submission_attempts,
    REV as reversals,
    CTRL as control_time,
    HEAD as head_strikes,
    BODY as body_strikes,
    LEG as leg_strikes,
    DISTANCE as distance_strikes,
    CLINCH as clinch_strikes,
    GROUND as ground_strikes
FROM {{ source('ufc', 'fight_stats') }}