with src_ufc_fight_results as (
	select
		ufr.EVENT as event
		, trim(substr(BOUT, 1, instr(BOUT, ' vs. ') - 1)) as red_corner
		, trim(substr(BOUT, instr(BOUT, ' vs. ') + 5)) as blue_corner
		, case
			when OUTCOME = 'W/L' then 'red'
			when OUTCOME = 'L/W' then 'blue'
			when OUTCOME = 'D/D' then 'draw'
			when OUTCOME = 'NC/NC' then 'no contests'
		end as outcome
		, WEIGHTCLASS as weightclass
		, METHOD as method
		, ROUND as round
		, TIME as time
		, "TIME FORMAT" as time_format
		, REFEREE as referee
		, DETAILS as details
		, DATE as date
		, LOCATION as location
		, ufr.URL as url
-- 		, first_value(weightclass)over(partition by red_corner order by date desc)
	from
		ufc_fight_results as ufr
)

, gaha as (
select
	ufr.event
	, ufr.date
	, red_corner
	, blue_corner
	, red.date
	, last_value(red.significant_strikes_landed_per_minute) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_significant_strikes_landed_per_minute
	, last_value(red.significant_striking_accuracy) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_significant_striking_accuracy
	, last_value(red.significant_strikes_absorbed_per_minute) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_significant_strikes_absorbed_per_minute
	, last_value(red.significant_strike_defence) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_significant_strike_defence
	, last_value(red.average_takedowns_landed_per_15_minutes) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_average_takedowns_landed_per_15_minutes
	, last_value(red.takedown_accuracy) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_takedown_accuracy
	, last_value(red.takedown_defense) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_takedown_defense
	, last_value(red.average_submissions_attempted_per_15_minutes) over(partition by ufr.event, red_corner order by red.date rows between unbounded preceding and unbounded following) as red_average_submissions_attempted_per_15_minutes
	, last_value(blue.significant_strikes_landed_per_minute) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_significant_strikes_landed_per_minute
	, last_value(blue.significant_striking_accuracy) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_significant_striking_accuracy
	, last_value(blue.significant_strikes_absorbed_per_minute) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_significant_strikes_absorbed_per_minute
	, last_value(blue.significant_strike_defence) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_significant_strike_defence
	, last_value(blue.average_takedowns_landed_per_15_minutes) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_average_takedowns_landed_per_15_minutes
	, last_value(blue.takedown_accuracy) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_takedown_accuracy
	, last_value(blue.takedown_defense) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_takedown_defense
	, last_value(blue.average_submissions_attempted_per_15_minutes) over(partition by ufr.event, blue_corner order by blue.date rows between unbounded preceding and unbounded following) as blue_average_submissions_attempted_per_15_minutes
	, case when outcome = 'red' then 1
		when outcome = 'blue' then 0
		when outcome = 'draw' then 0.5
		else null end as outcome
from
	src_ufc_fight_results as ufr
	left join fighter_stats_pre as red
		on ufr.red_corner = red.fighter
		and ufr.date > red.date
	left join fighter_stats_pre as blue
		on ufr.blue_corner = blue.fighter
		and ufr.date > blue.date
-- group by
-- 	ufr.event
-- 	, red_corner
-- 	, blue_corner
order by
	ufr.date desc
)

, pre_ml as (
select
	"event"
	, date
	, red_corner
	, blue_corner
	, max(red_significant_strikes_landed_per_minute) as red_significant_strikes_landed_per_minute
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
	gaha
-- where
-- 	red_corner like '%taira%'
group by
	event
	, red_corner
	, blue_corner
order by
	date desc
)

select
	red_significant_strikes_landed_per_minute
	, coalesce(red_significant_striking_accuracy, 0) as red_significant_striking_accuracy
	, red_significant_strikes_absorbed_per_minute
	, coalesce(red_significant_strike_defence, 0) as red_significant_strike_defence
	, red_average_takedowns_landed_per_15_minutes
	, coalesce(red_takedown_accuracy, 0) as red_takedown_accuracy
	, coalesce(red_takedown_defense, 0) as red_takedown_defense
	, red_average_submissions_attempted_per_15_minutes
	, blue_significant_strikes_landed_per_minute
	, coalesce(blue_significant_striking_accuracy, 0) as blue_significant_striking_accuracy
	, blue_significant_strikes_absorbed_per_minute
	, coalesce(blue_significant_strike_defence, 0) as blue_significant_strike_defence
	, blue_average_takedowns_landed_per_15_minutes
	, coalesce(blue_takedown_accuracy, 0) as blue_takedown_accuracy
	, coalesce(blue_takedown_defense, 0) as blue_takedown_defense
	, blue_average_submissions_attempted_per_15_minutes
	, outcome
from
	pre_ml
where
	red_significant_strikes_landed_per_minute is not null
	and blue_significant_strikes_landed_per_minute is not null
	and outcome is not null
order by
	date desc
