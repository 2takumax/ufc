with src_fight_stats as (
    select * from {{ ref('src_fight_stats') }}
)

, preprocessing_fight_stats as (
    select
        trim(event_name) as event_name
        , event_date
        , location
        , trim(bout) as bout
        , round
        , trim(fighter_name) as fighter_name
        , case
            when trim(split(bout, ' vs. ')[0]) = fighter_name then trim(split(bout, ' vs. ')[1])
            else trim(split(bout, ' vs. ')[0])
        end as opponent_name
        , kd
        , split(sig_str, ' of ')[0]::integer as sig_str
        , split(sig_str, ' of ')[1]::integer as sig_str_total
        , case when sig_str_rate != '---' then replace(sig_str_rate, '%', '')::integer else null end as sig_str_rate
        , split(total_str, ' of ')[0]::integer as str
        , split(total_str, ' of ')[1]::integer as str_total
        , split(td, ' of ')[0]::integer as td
        , split(td, ' of ')[1]::integer as td_total
        , case when td_rate != '---' then replace(td_rate, '%', '')::integer else null end as td_rate
        , sub_att
        , rev
        , case when ctrl != '--' then split(ctrl, ':')[0]::integer * 60 + split(ctrl, ':')[1]::integer else null end as ctrl_time_sec
        , split(head, ' of ')[0]::integer as head
        , split(head, ' of ')[1]::integer as head_total
        , split(body, ' of ')[0]::integer as body
        , split(body, ' of ')[1]::integer as body_total
        , split(leg, ' of ')[0]::integer as leg
        , split(leg, ' of ')[1]::integer as leg_total
        , split(distance, ' of ')[0]::integer as distance
        , split(distance, ' of ')[1]::integer as distance_total
        , split(clinch, ' of ')[0]::integer as clinch
        , split(clinch, ' of ')[1]::integer as clinch_total
        , split(ground, ' of ')[0]::integer as ground
        , split(ground, ' of ')[1]::integer as ground_total
    from
        src_fight_stats
)

select
    pfs.event_name
    , pfs.event_date
    , pfs.location
    , pfs.bout
    , pfs.round
    , pfs.fighter_name
    , pfs.opponent_name
    , pfs.kd
    , pfs.sig_str
    , pfs.sig_str_total
    , pfs.sig_str_rate
    , pfs.str
    , pfs.str_total
    , pfs.td
    , pfs.td_total
    , pfs.td_rate
    , pfs.sub_att
    , pfs.rev
    , pfs.ctrl_time_sec
    , pfs.head
    , pfs.head_total
    , pfs.body
    , pfs.body_total
    , pfs.leg
    , pfs.leg_total
    , pfs.distance
    , pfs.distance_total
    , pfs.clinch
    , pfs.clinch_total
    , pfs.ground
    , pfs.ground_total
    , opfs.kd as opponent_kd
    , opfs.sig_str as opponent_sig_str
    , opfs.sig_str_total as opponent_sig_str_total
    , opfs.sig_str_rate as opponent_sig_str_rate
    , opfs.str as opponent_str
    , opfs.str_total as opponent_str_total
    , opfs.td as opponent_td
    , opfs.td_total as opponent_td_total
    , opfs.td_rate as opponent_td_rate
    , opfs.sub_att as opponent_sub_att
    , opfs.rev as opponent_rev
    , opfs.ctrl_time_sec as opponent_ctrl_time_sec
    , opfs.head as opponent_head
    , opfs.head_total as opponent_head_total
    , opfs.body as opponent_body
    , opfs.body_total as opponent_body_total
    , opfs.leg as opponent_leg
    , opfs.leg_total as opponent_leg_total
    , opfs.distance as opponent_distance
    , opfs.distance_total as opponent_distance_total
    , opfs.clinch as opponent_clinch
    , opfs.clinch_total as opponent_clinch_total
    , opfs.ground as opponent_ground
    , opfs.ground_total as opponent_ground_total
from
    preprocessing_fight_stats as pfs
    left join preprocessing_fight_stats as opfs
        on pfs.event_name = opfs.event_name
        and pfs.bout = opfs.bout
        and pfs.round = opfs.round
        and pfs.opponent_name = opfs.fighter_name
