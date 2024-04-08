with src_fight_stats as (
    select * from {{ ref('src_fight_stats') }}
)

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
    , split(ctrl, ':')[0]::integer * 60 + split(ctrl, ':')[1]::integer as ctrl_time_sec
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
