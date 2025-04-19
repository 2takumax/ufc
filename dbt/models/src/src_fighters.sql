with raw_fighters as (
    select * from {{ source('ufc', 'fighters') }}
)

select
    fighter as fighter_name
    , record
    , height
    , weight
    , reach
    , stance
    , dob as birthday
    , slpm
    , str_acc
    , sapm
    , str_def
    , td_avg
    , td_acc
    , td_def
    , sub_avg
    , url
from
    raw_fighters
