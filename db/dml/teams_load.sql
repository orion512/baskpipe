INSERT INTO public.teams (full_name, short_name, "location")
select *
from (
	select trim(home_team_full_name) as full_name, upper(trim(home_team)) as short_name,
	trim(substring(home_team_full_name FROM '^(.*)\s[^\s]+$')) AS location
	from staging.st_daily_games
	union
	select trim(away_team_full_name) as full_name, upper(trim(away_team)) as short_name,
	trim(substring(away_team_full_name FROM '^(.*)\s[^\s]+$')) AS location
	from staging.st_daily_games
) sub
where not exists (
	select 1
	from teams t
	where t.short_name = sub.short_name
)