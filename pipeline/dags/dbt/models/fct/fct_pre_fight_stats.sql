with fct_fight_results as (
    select * from {{ ref('fct_fight_results') }}
)

, fct_fight_stats as (
    select * from {{ ref('fct_fight_stats') }}
)

, dim_fighters as (
    select * from {{ ref('dim_fighters') }}
)

, fight_stats_total_round as (
    select
		event_name
		, event_date
		, bout
		, fighter_name
		, sum(sig_str) as sig_str
		, sum(sig_str_total) as sig_str_total
		, sum(td) as td
		, sum(td_total) as td_total
		, sum(sub_att) as sub_att
		, sum(opponent_sig_str) as opponent_sig_str
		, sum(opponent_sig_str_total) as opponent_sig_str_total
		, sum(opponent_td) as opponent_td
		, sum(opponent_td_total) as opponent_td_total
    from
        fct_fight_stats
    group by
        event_name
        , event_date
        , bout
        , fighter_name
)

select
    fstr.event_name
	, fstr.event_date
	, fstr.fighter_name
	, sum(sig_str)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(ffr.total_time_sec)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 60 as significant_strikes_landed_per_minute
	, sum(sig_str)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(sig_str_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 100 as significant_striking_accuracy
	, sum(opponent_sig_str)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(ffr.total_time_sec)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 60 as significant_strikes_absorbed_per_minute
	, (sum(opponent_sig_str_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) - sum(opponent_sig_str)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row)) / cast(nullif(sum(opponent_sig_str_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 100 as significant_strike_defence
	, sum(td)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(ffr.total_time_sec)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 60 * 15 as average_takedowns_landed_per_15_minutes
	, sum(td)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(td_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 100 as takedown_accuracy
	, (sum(opponent_td_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) - sum(opponent_td)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row)) / cast(nullif(sum(opponent_td_total)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 100 as takedown_defense
	, sum(sub_att)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row) / cast(nullif(sum(ffr.total_time_sec)over(partition by fstr.fighter_name order by fstr.event_date rows between unbounded preceding and current row), 0) as float) * 60 * 15 as average_submissions_attempted_per_15_minutes
from
    fight_stats_total_round as fstr
    left join fct_fight_results as ffr
        on fstr.event_name = ffr.event_name
        and replace(fstr.bout, ' ', '') = replace(ffr.bout, ' ', '')
