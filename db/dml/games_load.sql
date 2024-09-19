INSERT INTO public.games (br_game_id, br_game_url, game_time, arena_name, attendance, playin_game, playoff_game, playoff_conference, playoff_round, playoff_game_number)
select
	upper(trim(game_id)) as br_game_id,
	trim(game_url) as br_game_url,
	
	game_time::timestamp,
	initcap(trim(arena_name)) as arena_name,
	attendance::int,
	playin_game::bool,
	playoff_game::bool,
	trim(lower(playoff_conference)) as playoff_conference,
	trim(lower(playoff_round)) as playoff_round,
	trim(playoff_game_number)::int as playoff_game_number
from staging.st_daily_games sdg
where not exists (
	select 1
	from public.games g
	where g.br_game_id = upper(trim(sdg.game_id))
)
order by sdg.game_time::timestamp