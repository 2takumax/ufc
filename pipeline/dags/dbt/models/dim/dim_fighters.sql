{{ config(
    materialized='table'
) }}

WITH fighters_base AS (
    SELECT * FROM {{ ref('src_fighters') }}
),

parsed_fighters AS (
    SELECT
        fighter_name,
        fight_record,
        nickname,
        
        -- Parse fight record (W-L-D format, sometimes with NC in parentheses)
        TRY_TO_NUMBER(SPLIT_PART(fight_record, '-', 1)) as wins,
        TRY_TO_NUMBER(SPLIT_PART(fight_record, '-', 2)) as losses,
        CASE
            WHEN CONTAINS(fight_record, '(')
            THEN TRY_TO_NUMBER(TRIM(SPLIT_PART(SPLIT_PART(fight_record, '-', 3), '(', 1)))
            ELSE TRY_TO_NUMBER(SPLIT_PART(fight_record, '-', 3))
        END as draws,
        CASE
            WHEN CONTAINS(fight_record, '(')
            THEN TRY_TO_NUMBER(REPLACE(SPLIT_PART(SPLIT_PART(fight_record, '(', 2), ')', 1), 'NC', ''))
            ELSE 0
        END as no_contests,
        
        -- Parse physical attributes
        CASE
            WHEN height != '--' AND height IS NOT NULL
            THEN TRY_TO_NUMBER(SPLIT_PART(height, '''', 1)) * 12 + TRY_TO_NUMBER(REPLACE(SPLIT_PART(height, '''', 2), '"', ''))
            ELSE NULL
        END as height_inches,
        
        CASE
            WHEN weight != '--' AND weight IS NOT NULL
            THEN TRY_TO_NUMBER(REPLACE(weight, ' lbs.', ''))
            ELSE NULL
        END as weight_lbs,
        
        CASE
            WHEN reach != '--' AND reach IS NOT NULL
            THEN TRY_TO_NUMBER(REPLACE(reach, '"', ''))
            ELSE NULL
        END as reach_inches,
        
        stance,
        
        CASE
            WHEN date_of_birth != '--' AND date_of_birth IS NOT NULL
            THEN TRY_TO_DATE(date_of_birth, 'Mon DD, YYYY')
            ELSE NULL
        END as date_of_birth,
        
        -- Parse fight statistics (remove % signs and convert)
        TRY_TO_NUMBER(sig_strikes_landed_per_min) as slpm,
        TRY_TO_NUMBER(REPLACE(striking_accuracy, '%', '')) as str_acc_pct,
        TRY_TO_NUMBER(sig_strikes_absorbed_per_min) as sapm,
        TRY_TO_NUMBER(REPLACE(striking_defense, '%', '')) as str_def_pct,
        TRY_TO_NUMBER(takedowns_avg_per_15min) as td_avg,
        TRY_TO_NUMBER(REPLACE(takedown_accuracy, '%', '')) as td_acc_pct,
        TRY_TO_NUMBER(REPLACE(takedown_defense, '%', '')) as td_def_pct,
        TRY_TO_NUMBER(submissions_avg_per_15min) as sub_avg,
        
        data_timestamp
    FROM fighters_base
)

SELECT
    fighter_name,
    nickname,
    fight_record,
    wins,
    losses,
    draws,
    no_contests,
    wins + losses + draws + no_contests as total_fights,
    CASE 
        WHEN wins + losses + draws > 0 
        THEN ROUND(wins::FLOAT / (wins + losses + draws), 3)
        ELSE NULL
    END as win_rate,
    height_inches,
    ROUND(height_inches * 2.54, 1) as height_cm,
    weight_lbs,
    ROUND(weight_lbs * 0.453592, 1) as weight_kg,
    reach_inches,
    ROUND(reach_inches * 2.54, 1) as reach_cm,
    stance,
    date_of_birth,
    DATEDIFF(year, date_of_birth, CURRENT_DATE()) as age,
    slpm,
    str_acc_pct,
    sapm,
    str_def_pct,
    td_avg,
    td_acc_pct,
    td_def_pct,
    sub_avg,
    data_timestamp,
    ROW_NUMBER() OVER (ORDER BY fighter_name) as fighter_id
FROM parsed_fighters