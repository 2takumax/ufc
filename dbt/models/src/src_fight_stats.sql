with raw_fight_stats as (
    select * from {{ source('ufc', 'fight_stats') }}
)

select
    event as event_name
    , bout
    , round
    , fighter as fighter_name
    , kd
    , sig_str
    , sig_str_rate
    , total_str
    , td
    , td_rate
    , sub_att
    , rev
    , ctrl
    , head
    , body
    , leg
    , distance
    , clinch
    , ground
    , date as event_date
    , location
from
    raw_fight_stats
