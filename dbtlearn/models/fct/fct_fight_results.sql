with src_fight_results as (
    select * from {{ ref('src_fight_results') }}
)

select
    trim(event_name) as event_name
    , bout
    , trim(split(bout, ' vs. ')[0]) as red_corner
    , trim(split(bout, ' vs. ')[1]) as blue_corner
    , case
        when outcome = 'W/L' then 'red'
        when outcome = 'L/W' then 'blue'
        when outcome = 'D/D' then 'draw'
        when outcome = 'NC/NC' then 'no contests'
    end as outcome
    , weightclass
    , method
    , round
    , time
    , ((round - 1) * 300) + split(time, ':')[0]::integer * 60 + split(time, ':')[1]::integer as total_time_sec
    , time_format
    , referee
    , details
    , date
    , location
    , url
from
    src_fight_results
