with pre as (
	select
		trim("EVENT") as event
		, "DATE" as date
		, "LOCATION" as location
		, trim("BOUT") as bout
		, ROUND as round
		, trim("FIGHTER") as fighter
		, case
			when TRIM(SUBSTR(BOUT, 1, INSTR(BOUT, ' vs.') - 1)) = FIGHTER then TRIM(SUBSTR(BOUT, INSTR(BOUT, ' vs.') + 4))
			else TRIM(SUBSTR(BOUT, 1, INSTR(BOUT, ' vs.') - 1))
		end as opponent
		, KD as kd
		, substr("SIG.STR.", 1, instr("SIG.STR.", ' of ') - 1) as sig_str
        , substr("SIG.STR.", instr("SIG.STR.", ' of ') + 4) as sig_str_total
		, "SIG.STR. %" as sig_str_rate
		, "TOTAL STR." as total_str
		, substr(TD, 1, instr(TD, ' of ') - 1) as td
        , substr(TD, instr(TD, ' of ') + 4) as td_total
		, "TD %" as td_rate
		, "SUB.ATT" as sub_att
		, "REV." as rev
		, CTRL as ctrl
		, HEAD as head
		, BODY as body
		, LEG as leg
		, DISTANCE as distance
		, CLINCH as clinch
		, GROUND as ground
	from
		ufc_fight_stats
-- 	where
-- 		FIGHTER like '%taira%'
)

, ufc_fight_result as (
	select
		trim("EVENT") as EVENT
		, trim("BOUT") as BOUT
		, ROUND
		, TIME
		, (substr(time, 1, instr(time, ':') - 1) * 60) -- 分を秒に変換
          + (substr(time, instr(time, ':') + 1))       -- 秒を加算
          as seconds
        , (round - 1) * 300 + (substr(time, 1, instr(time, ':') - 1) * 60) + (substr(time, instr(time, ':') + 1))  as total_minute
	from
		ufc_fight_results
)

, aho as (
	select
		pre.*
		, pre2.sig_str as opponent_sig_str
		, pre2.sig_str_total as opponent_sig_str_total
		, pre2.td as opponent_td
		, pre2.td_total as opponent_td_total
		, ufr.total_minute
	from
		pre
		left join pre as pre2
			on pre.event = pre2.event
			and pre.bout = pre2.bout
			and pre.round = pre2.round
			and pre.opponent = pre2.fighter
		left join ufc_fight_result as ufr
			on pre.event = ufr.EVENT
			and replace(pre.bout, ' ', '') = replace(ufr.BOUT, ' ', '')
	where
		pre.fighter like '%taira%'
)

, baka as (
	select
		event
		, max(date) as date
		, max(bout) as bout
		, fighter
		, sum(sig_str) as sig_str
		, sum(sig_str_total) as sig_str_total
		, sum(td) as td
		, sum(td_total) as td_total
		, sum(sub_att) as sub_att
		, sum(opponent_sig_str) as opponent_sig_str
		, sum(opponent_sig_str_total) as opponent_sig_str_total
		, sum(opponent_td) as opponent_td
		, sum(opponent_td_total) as opponent_td_total
		, max(total_minute) as total_minute
	from
		aho
	group by
		event
		, fighter
)

select
	event
	, date
	, fighter
	, sum(sig_str)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(total_minute)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 60 as significant_strikes_landed_per_minute
	, sum(sig_str)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(sig_str_total)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 100 as significant_striking_accuracy
	, sum(opponent_sig_str)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(total_minute)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 60 as significant_strikes_absorbed_per_minute
	, (sum(opponent_sig_str_total)over(partition by fighter order by date rows between unbounded preceding and current row) - sum(opponent_sig_str)over(partition by fighter order by date rows between unbounded preceding and current row)) / cast(sum(opponent_sig_str_total)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 100 as significant_strike_defence
	, sum(td)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(total_minute)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 60 * 15 as average_takedowns_landed_per_15_minutes
	, sum(td)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(td_total)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 100 as takedown_accuracy
	, (sum(opponent_td_total)over(partition by fighter order by date rows between unbounded preceding and current row) - sum(opponent_td)over(partition by fighter order by date rows between unbounded preceding and current row)) / cast(sum(opponent_td_total)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 100 as takedown_defense
	, sum(sub_att)over(partition by fighter order by date rows between unbounded preceding and current row) / cast(sum(total_minute)over(partition by fighter order by date rows between unbounded preceding and current row) as float) * 60 * 15 as average_submissions_attempted_per_15_minutes
	, row_number()over(partition by fighter order by date rows between unbounded preceding and current row) as row_num
from
	baka
order by
	date
	