with fct_fight_results as (
    select * from {{ ref('fct_fight_results') }}
)

, fct_fight_stats as (
    select * from {{ ref('fct_fight_stats') }}
)

, dim_fighters as (
    select * from {{ ref('dim_fighters') }}
)

, join_opponent_stats as (
    select
        ffs1.*
		, ffs2.sig_str as opponent_sig_str
		, ffs2.sig_str_total as opponent_sig_str_total
		, ffs2.td as opponent_td
		, ffs2.td_total as opponent_td_total
		, ffr.total_minute
    from
        fct_fight_stats as ffs1
        left join fct_fight_stats as ffs2
            on ffs1.event_name = ffs2.event_name
            and ffs1.bout = ffs2.bout
            and ffs1.round = ffs2.round
            and ffs1.opponent_name = ffs2.fighter_name
        left join fct_fight_results as ffr
            on ffs1.event_name = ffr.event_name
            and replace(ffs1.bout, ' ', '') = replace(ffr.bout, ' ', '')
)

select
    *
from
    join_opponent_stats
