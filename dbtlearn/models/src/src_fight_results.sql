with raw_fight_results as (
    select * from {{ source('ufc', 'fight_results') }}
)

select
    event as event_name
    , bout
    , outcome
    , weightclass
    , method
    , round
    , time
    , time_format
    , referee
    , details
    , url
    , date
    , location
from
    raw_fight_results
