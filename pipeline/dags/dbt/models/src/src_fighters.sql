{{ config(
    materialized='ephemeral'
) }}

SELECT
    NAME as fighter_name,
    FIGHT_RECORD as fight_record,
    NICKNAME as nickname,
    HEIGHT as height,
    WEIGHT as weight,
    REACH as reach,
    STANCE as stance,
    DOB as date_of_birth,
    SLPM as sig_strikes_landed_per_min,
    STR_ACC as striking_accuracy,
    SAPM as sig_strikes_absorbed_per_min,
    STR_DEF as striking_defense,
    TD_AVG as takedowns_avg_per_15min,
    TD_ACC as takedown_accuracy,
    TD_DEF as takedown_defense,
    SUB_AVG as submissions_avg_per_15min,
    TIMESTAMP as data_timestamp
FROM {{ source('ufc', 'fighters') }}