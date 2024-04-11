with fct_fight_results as (
    select * from {{ ref('fct_fight_results') }}
)

, fct_pre_fight_stats as (
    select * from {{ ref('fct_pre_fight_stats') }}
)

, red_vs_blue_pre_stats as (
select
    ffr.event_name
	, ffr.event_date
	, red_corner
	, blue_corner
	, last_value(red.significant_strikes_landed_per_minute) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_significant_strikes_landed_per_minute
	, last_value(red.significant_striking_accuracy) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_significant_striking_accuracy
	, last_value(red.significant_strikes_absorbed_per_minute) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_significant_strikes_absorbed_per_minute
	, last_value(red.significant_strike_defence) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_significant_strike_defence
	, last_value(red.average_takedowns_landed_per_15_minutes) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_average_takedowns_landed_per_15_minutes
	, last_value(red.takedown_accuracy) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_takedown_accuracy
	, last_value(red.takedown_defense) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_takedown_defense
	, last_value(red.average_submissions_attempted_per_15_minutes) over(partition by ffr.event_name, red_corner order by red.event_date rows between unbounded preceding and unbounded following) as red_average_submissions_attempted_per_15_minutes
	, last_value(blue.significant_strikes_landed_per_minute) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_significant_strikes_landed_per_minute
	, last_value(blue.significant_striking_accuracy) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_significant_striking_accuracy
	, last_value(blue.significant_strikes_absorbed_per_minute) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_significant_strikes_absorbed_per_minute
	, last_value(blue.significant_strike_defence) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_significant_strike_defence
	, last_value(blue.average_takedowns_landed_per_15_minutes) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_average_takedowns_landed_per_15_minutes
	, last_value(blue.takedown_accuracy) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_takedown_accuracy
	, last_value(blue.takedown_defense) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_takedown_defense
	, last_value(blue.average_submissions_attempted_per_15_minutes) over(partition by ffr.event_name, blue_corner order by blue.event_date rows between unbounded preceding and unbounded following) as blue_average_submissions_attempted_per_15_minutes
	, case when ffr.outcome = 'red' then 1
		when ffr.outcome = 'blue' then 0
		when ffr.outcome = 'draw' then 0.5
		else null end as outcome
from
	fct_fight_results as ffr
	left join fct_pre_fight_stats as red
		on ffr.red_corner = red.fighter_name
		and ffr.event_date > red.event_date
	left join fct_pre_fight_stats as blue
		on ffr.blue_corner = blue.fighter_name
		and ffr.event_date > blue.event_date
)

select
	max(red_significant_strikes_landed_per_minute) as red_significant_strikes_landed_per_minute
	, max(red_significant_striking_accuracy) as red_significant_striking_accuracy
	, max(red_significant_strikes_absorbed_per_minute) as red_significant_strikes_absorbed_per_minute
	, max(red_significant_strike_defence) as red_significant_strike_defence
	, max(red_average_takedowns_landed_per_15_minutes) as red_average_takedowns_landed_per_15_minutes
	, max(red_takedown_accuracy) as red_takedown_accuracy
	, max(red_takedown_defense) as red_takedown_defense
	, max(red_average_submissions_attempted_per_15_minutes) as red_average_submissions_attempted_per_15_minutes
	, max(blue_significant_strikes_landed_per_minute) as blue_significant_strikes_landed_per_minute
	, max(blue_significant_striking_accuracy) as blue_significant_striking_accuracy
	, max(blue_significant_strikes_absorbed_per_minute) as blue_significant_strikes_absorbed_per_minute
	, max(blue_significant_strike_defence) as blue_significant_strike_defence
	, max(blue_average_takedowns_landed_per_15_minutes) as blue_average_takedowns_landed_per_15_minutes
	, max(blue_takedown_accuracy) as blue_takedown_accuracy
	, max(blue_takedown_defense) as blue_takedown_defense
	, max(blue_average_submissions_attempted_per_15_minutes) as blue_average_submissions_attempted_per_15_minutes
	, max(outcome) as outcome
from
	red_vs_blue_pre_stats
group by
	event_name
    , event_date
	, red_corner
	, blue_corner
order by
	event_date desc
