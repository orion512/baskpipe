create table if not exists game_team_stats (
	id serial primary key, 
	
	game_id integer references games(id),
	team_id integer references teams(id),
	is_home bool not null,
	
	fg integer,
	fga integer,
	fg_pct float,
	fg3 integer,
	fg3a integer,
	fg3_pct float,
	ft integer,
	fta integer,
	ft_pct float,
	orb integer,
	drb integer,
	trb integer,
	ast integer,
	stl integer,
	blk integer,
	tov integer,
	pf integer,
	pts integer,
	
	ts_pct float,
	efg_pct float,
	fg3a_per_fga_pct float,
	fta_per_fga_pct float,
	orb_pct float,
	drb_pct float,
	trb_pct float,
	ast_pct float,
	stl_pct float,
	blk_pct float,
	tov_pct float,
	off_rtg float,
	def_rtg float,

	inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
)