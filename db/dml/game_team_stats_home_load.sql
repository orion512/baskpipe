INSERT INTO public.game_team_stats (game_id, team_id, is_home, fg, fga, fg_pct, fg3, fg3a, fg3_pct, ft, fta, ft_pct, orb, drb, trb, ast, stl, blk, tov, pf, pts, ts_pct, efg_pct, fg3a_per_fga_pct, fta_per_fga_pct, orb_pct, drb_pct, trb_pct, ast_pct, stl_pct, blk_pct, tov_pct, off_rtg, def_rtg)
SELECT
    g.id AS game_id,
    t.id AS team_id,
    true AS is_home,
    
    home_fg::int AS fg,
    home_fga::int AS fga,
    home_fg_pct::float AS fg_pct,
    home_fg3::int AS fg3,
    home_fg3a::int AS fg3a,
    home_fg3_pct::float AS fg3_pct,
    home_ft::int AS ft,
    home_fta::int AS fta,
    home_ft_pct::float AS ft_pct,
    home_orb::int AS orb,
    home_drb::int AS drb,
    home_trb::int AS trb,
    home_ast::int AS ast,
    home_stl::int AS stl,
    home_blk::int AS blk, 
    home_tov::int AS tov,
    home_pf::int AS pf,
    home_pts::int AS pts,

    home_ts_pct::float AS ts_pct, 
    home_efg_pct::float AS efg_pct,
    home_fg3a_per_fga_pct::float AS fg3a_per_fga_pct,
    home_fta_per_fga_pct::float AS fta_per_fga_pct,
    home_orb_pct::float AS orb_pct,
    home_drb_pct::float AS drb_pct,
    home_trb_pct::float AS trb_pct, 
    home_ast_pct::float AS ast_pct,
    home_stl_pct::float AS stl_pct,
    home_blk_pct::float AS blk_pct, 
    home_tov_pct::float AS tov_pct,
    home_off_rtg::float AS off_rtg, 
    home_def_rtg::float AS def_rtg
FROM staging.st_daily_games sdg
JOIN public.games g ON upper(trim(sdg.game_id)) = g.br_game_id
JOIN public.teams t ON upper(trim(sdg.home_team)) = t.short_name
where not exists (
	select 1
	from public.game_team_stats gts 
	where gts.game_id = g.id and gts.team_id = t.id
)