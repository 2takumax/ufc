with src_fighters as (
    select * from {{ ref('src_fighters') }}
)

select
    fighter_name
    , cast(split(record, '-')[0] as integer) as wins
    , cast(split(record, '-')[1] as integer) as losses
    , case
        when record like '%(%)%' then cast(trim(split(split(record, '-')[2], '(')[0]) as integer)
        else cast(split(record, '-')[2] as integer)
    end as draws
    , case
        when record like '%(%)%' then cast(split(split(split(record, '-')[2], '(')[1], ' ')[0] as integer)
        else 0
    end as no_contests
    , case
        when height != '--' then cast(left(split(height, ' ')[0], 1) as integer) * 12 * 2.54 + cast(split(left(split(height, ' ')[1], 2), '"')[0] as integer) * 2.54
        else null
    end as height_cm
    , case when weight != '--' then cast(split(weight, ' ')[0] as integer) * 0.453592 else null end as weight_kg
    , case when reach != '--' then cast(left(reach, 2) as integer) * 2.54 else null end as reach_cm
    , stance
    , case when birthday != '--' then to_date(birthday, 'MON DD, YYYY') else null end as birthday
    , slpm
    , cast(replace(str_acc, '%', '') as integer) as str_acc
    , sapm
    , cast(replace(str_def, '%', '') as integer) as str_def
    , td_avg
    , cast(replace(td_acc, '%', '') as integer) as td_acc
    , cast(replace(td_def, '%', '') as integer) as td_def
    , sub_avg
    , url
from
    src_fighters
