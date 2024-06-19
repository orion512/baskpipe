INSERT INTO public.games (br_game_id, br_game_url, game_time, arena_name, playin_game, attendance)
select
	upper(trim(game_id)) as br_game_id,
	trim(game_url) as br_game_url,
	game_time::timestamp,
	initcap(trim(arena_name)) as arena_name,
	playin_game::bool,
	attendance::int
from staging.st_daily_games sdg
where not exists (
	select 1
	from public.games g
	where g.br_game_id = upper(trim(sdg.game_id))
)
order by sdg.game_time::timestamp