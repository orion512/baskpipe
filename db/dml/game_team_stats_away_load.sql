INSERT INTO public.game_team_stats (game_id, team_id, is_home, fg, fga, fg_pct, fg3, fg3a, fg3_pct, ft, fta, ft_pct, orb, drb, trb, ast, stl, blk, tov, pf, pts, ts_pct, efg_pct, fg3a_per_fga_pct, fta_per_fga_pct, orb_pct, drb_pct, trb_pct, ast_pct, stl_pct, blk_pct, tov_pct, off_rtg, def_rtg)
SELECT
    g.id AS game_id,
    t.id AS team_id,
    false AS is_home,
    
    away_fg::int AS fg,
    away_fga::int AS fga,
    away_fg_pct::float AS fg_pct,
    away_fg3::int AS fg3,
    away_fg3a::int AS fg3a,
    away_fg3_pct::float AS fg3_pct,
    away_ft::int AS ft,
    away_fta::int AS fta,
    away_ft_pct::float AS ft_pct,
    away_orb::int AS orb,
    away_drb::int AS drb,
    away_trb::int AS trb,
    away_ast::int AS ast,
    away_stl::int AS stl,
    away_blk::int AS blk, 
    away_tov::int AS tov,
    away_pf::int AS pf,
    away_pts::int AS pts,

    away_ts_pct::float AS ts_pct, 
    away_efg_pct::float AS efg_pct,
    away_fg3a_per_fga_pct::float AS fg3a_per_fga_pct,
    away_fta_per_fga_pct::float AS fta_per_fga_pct,
    away_orb_pct::float AS orb_pct,
    away_drb_pct::float AS drb_pct,
    away_trb_pct::float AS trb_pct, 
    away_ast_pct::float AS ast_pct,
    away_stl_pct::float AS stl_pct,
    away_blk_pct::float AS blk_pct, 
    away_tov_pct::float AS tov_pct,
    away_off_rtg::float AS off_rtg, 
    away_def_rtg::float AS def_rtg
FROM staging.st_daily_games sdg
JOIN public.games g ON upper(trim(sdg.game_id)) = g.br_game_id
JOIN public.teams t ON upper(trim(sdg.away_team)) = t.short_name
where not exists (
	select 1
	from public.game_team_stats gts 
	where gts.game_id = g.id and gts.team_id = t.id
)